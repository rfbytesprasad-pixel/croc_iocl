import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../data/ro_repository.dart';
import '../model/ro_config_model.dart';
import '../model/ro_model.dart';
import 'ro_event.dart';
import 'ro_state.dart';

class RoBloc extends Bloc<RoEvent, RoState> {
  final RoRepository _repository;

  /// Background reference data — NOT part of [RoState].
  RoConfigModel? _roConfig;
  RoConfigModel? get roConfig => _roConfig;

  /// The ESP's roAutoId — used for preset/pricechange packets.
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

  Future<void> _onProbeApi(
    ProbeApi event,
    Emitter<RoState> emit,
  ) async {
    if (state is RoLoaded) return;

    emit(const RoApiProbing());

    final workingUrl = await _repository.probeRoConfig(
      candidateIps: AppConstants.candidateIps,
    );

    if (workingUrl == null) {
      emit(const RoApiNotConfigured());
      return;
    }

    _repository.setBaseUrl(workingUrl);
    AppConstants.baseUrl = workingUrl;

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
        // Enrich roCode from /roconfig, or from /pump fallback if config failed.
        final effectiveRoCode = _roConfig?.roCode ?? _runtimeRoCode;
        final enriched = (ro.roCode == 0 && effectiveRoCode != null)
            ? RoModel(roCode: effectiveRoCode, address: ro.address)
            : ro;
        emit(RoLoaded(ro: enriched));

      case RoRepositoryError(:final message, :final type):
        emit(RoError(message: message, type: type));
    }
  }

  Future<void> _onLoadRoConfig(
    LoadRoConfig event,
    Emitter<RoState> emit,
  ) async {
    if (_roConfig != null) return;

    final result = await _repository.fetchRoConfig();

    switch (result) {
      case RoConfigRepositorySuccess(:final config):
        _roConfig = config;
        _runtimeRoCode = config.roCode;

        // If Home already loaded empty, re-emit with the real roCode.
        final current = state;
        if (current is RoLoaded && current.ro.roCode == 0) {
          emit(RoLoaded(ro: RoModel(
            roCode: config.roCode,
            address: current.ro.address,
          )));
        }

      case RoConfigRepositoryError(:final message):
        debugPrint('RO config load failed: $message. Trying /pump fallback...');
        await _tryLoadRuntimeRoCodeFromPump();

        final current = state;
        if (current is RoLoaded &&
            current.ro.roCode == 0 &&
            _runtimeRoCode != null) {
          emit(RoLoaded(ro: RoModel(
            roCode: _runtimeRoCode!,
            address: current.ro.address,
          )));
        }
    }
  }

  Future<void> _tryLoadRuntimeRoCodeFromPump() async {
    final result = await _repository.fetchPumpRoCode();
    switch (result) {
      case PumpRoCodeSuccess(:final roCode):
        _runtimeRoCode = roCode;
        debugPrint('Fallback: runtimeRoCode = $roCode (from /pump)');
      case PumpRoCodeError(:final message):
        debugPrint('Fallback pump fetch failed: $message');
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}