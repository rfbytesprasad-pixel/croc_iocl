import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../data/ro_repository.dart';
import '../model/ro_config_model.dart';
import 'ro_event.dart';
import 'ro_state.dart';
import '../model/ro_model.dart';

class RoBloc extends Bloc<RoEvent, RoState> {
  final RoRepository _repository;

  /// Background reference data — NOT part of [RoState].
  RoConfigModel? _roConfig;
  RoConfigModel? get roConfig => _roConfig;

  /// The ESP's roAutoId — used for preset/pricechange packets.
  /// Set from /roconfig.roCode if available, else from /pump.roautoid.
  /// Never hardcoded — each ESP has its own value.
  int? _runtimeRoCode;
  int? get runtimeRoCode => _runtimeRoCode;

  RoBloc({
    required RoRepository repository,
  })  : _repository = repository,
        super(const RoInitial()) {
    on<ProbeApi>(_onProbeApi);
    on<LoadRoDetails>(_onLoadRoDetails);
    on<LoadRoConfig>(_onLoadRoConfig);
  }

  /// Try every candidate IP in parallel. On success, swap the repository's
  /// base URL and chain into details + config loads. On failure, show
  /// the "API not configured" screen.
  Future<void> _onProbeApi(
    ProbeApi event,
    Emitter<RoState> emit,
  ) async {
    if (state is RoLoaded) return; // already running

    emit(const RoApiProbing());

    final workingUrl = await _repository.probeRoConfig(
      candidateIps: AppConstants.candidateIps,
    );

    if (workingUrl == null) {
      emit(const RoApiNotConfigured());
      return;
    }

    // Persist the working IP inside the repository / api client.
    _repository.setBaseUrl(workingUrl);
     AppConstants.baseUrl = workingUrl;

    // Now that we know the right URL, load details + config.
    add(const LoadRoDetails());
    add(const LoadRoConfig());
  }

  Future<void> _onLoadRoDetails(
    LoadRoDetails event,
    Emitter<RoState> emit,
  ) async {
    if (state is RoLoaded) return;

    emit(const RoLoading());

    final result = await _repository.fetchRoDetails();

    switch (result) {
  case RoRepositorySuccess(:final ro):
    // If /rodetails returned an empty model (e.g. 404), enrich the
    // roCode from /roconfig so Home shows the real outlet identity.
    final config = _roConfig;
    final enriched = (ro.roCode == 0 && config != null)
        ? RoModel(roCode: config.roCode, address: ro.address)
        : ro;
    emit(RoLoaded(ro: enriched));
  case RoRepositoryError(:final message, :final type):
    emit(RoError(message: message, type: type));
}
  }

  /// Loads `/roconfig` into memory. Deliberately does NOT emit any [RoState]
  /// because config is not UI state — it is reference data consumed by other
  /// screens. Failures are logged, not shown on Home.
  Future<void> _onLoadRoConfig(
    LoadRoConfig event,
    Emitter<RoState> emit,
  ) async {
    if (_roConfig != null) return;

    final result = await _repository.fetchRoConfig();

    switch (result) {
  case RoConfigRepositorySuccess(:final config):
    _roConfig = config;

    // If Home already loaded with an empty RoModel (because /rodetails
    // 404'd before /roconfig finished), re-emit with the real roCode.
    final current = state;
    if (current is RoLoaded && current.ro.roCode == 0) {
      emit(RoLoaded(ro: RoModel(
        roCode: config.roCode,
        address: current.ro.address,
      )));
    }

  case RoConfigRepositoryError(:final message):
    debugPrint('RO config load failed: $message');
}
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}