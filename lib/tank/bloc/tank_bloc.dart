import 'dart:async';

import 'package:croc_iocl_atos/core/constants.dart';
import 'package:croc_iocl_atos/tank/bloc/tank_event.dart';
import 'package:croc_iocl_atos/tank/bloc/tank_state.dart';
import 'package:croc_iocl_atos/tank/data/tank_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TankBloc extends Bloc<TankEvent, TankState> {
  final TankRepository _tankRepository;
  Timer? _pollingTimer;
  String? _siteId;

  TankBloc({required TankRepository tankRepository})
      : _tankRepository = tankRepository,
        super(const TankInitial()) {
    on<TankStartPolling>(_onStartPolling);
    on<TankStopPolling>(_onStopPolling);
    on<TankTimerTicked>(_onTimerTicked);
  }

  Future<void> _onStartPolling(
      TankStartPolling event, Emitter<TankState> emit) async {
    _siteId = event.siteId;

    //cancle any exiting timer
    _pollingTimer?.cancel();

    if (state is TankInitial) {
      emit(const TankLoading());
    }

    await _fetchAndEmit(emit);
    // Start timer for subsequent polls
    _pollingTimer = Timer.periodic(
      AppConstants.pumpPollingInterval,
      (_) => add(const TankTimerTicked()),
    );
  }

  void _onStopPolling(
    TankStopPolling event,
    Emitter<TankState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── _PumpTimerTicked ───────────────────────────────────────────────────────
  Future<void> _onTimerTicked(
    TankTimerTicked event,
    Emitter<TankState> emit,
  ) async {
    // If already loaded, mark as refreshing so UI can show subtle indicator
    if (state is TankLoaded) {
      emit((state as TankLoaded).copyWith(isRefreshing: true));
    }

    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<TankState> emit) async {
    final previousTanks = switch (state) {
      TankLoaded(:final tanks) => tanks,
      TankError(:final previoustanks) => previoustanks,
      _ => null,
    };

    final result = await _tankRepository.fetchTankStatus(siteId: _siteId);

    switch (result) {
      case TankRepositorySuccess(:final tanks):
        emit(TankLoaded(tanks: tanks));
      case TankRepositoryError(:final message, :final type):
        if (type == TankErrorType.parse) {
          emit(TankError(message: message, type: type, previoustanks: null));
        } else {
          emit(TankError(
              message: message, type: type, previoustanks: previousTanks));
        }
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _tankRepository.dispose();
    return super.close();
  }
}
