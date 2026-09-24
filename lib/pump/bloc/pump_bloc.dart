// lib/pump/bloc/pump_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../data/pump_repository.dart';

import 'pump_event.dart';
import 'pump_state.dart';

class PumpBloc extends Bloc<PumpEvent, PumpState> {
  final PumpRepository _repository;
  Timer? _pollingTimer;
  String? _siteId;

  PumpBloc({required PumpRepository repository})
      : _repository = repository,
        super(const PumpInitial()) {
    on<PumpStartPolling>(_onStartPolling);
    on<PumpStopPolling>(_onStopPolling);
    on<PumpTimerTicked>(_onTimerTicked);
  }

  // ── PumpStartPolling ───────────────────────────────────────────────────────
  Future<void> _onStartPolling(
    PumpStartPolling event,
    Emitter<PumpState> emit,
  ) async {
    _siteId = event.siteId;

    // Cancel any existing timer — safety net if called twice
    _pollingTimer?.cancel();

    // Only show loading spinner on very first fetch
    if (state is PumpInitial) {
      emit(const PumpLoading());
    }

    // Fetch immediately — don't make user wait 10s
    await _fetchAndEmit(emit);

    // Start timer for subsequent polls
    _pollingTimer = Timer.periodic(
      AppConstants.pumpPollingInterval,
      (_) => add(const PumpTimerTicked()),
    );
  }

  // ── PumpStopPolling ────────────────────────────────────────────────────────
  void _onStopPolling(
    PumpStopPolling event,
    Emitter<PumpState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── _PumpTimerTicked ───────────────────────────────────────────────────────
  Future<void> _onTimerTicked(
    PumpTimerTicked event,
    Emitter<PumpState> emit,
  ) async {
    // If already loaded, mark as refreshing so UI can show subtle indicator
    if (state is PumpLoaded) {
      emit((state as PumpLoaded).copyWith(isRefreshing: true));
    }

    await _fetchAndEmit(emit);
  }

  // ── Core fetch logic — shared by both handlers ────────────────────────────
  Future<void> _fetchAndEmit(Emitter<PumpState> emit) async {
    // Keep last known good data in case this fetch fails
    final previousPumps = switch (state) {
      PumpLoaded(:final pumps) => pumps,
      PumpError(:final previousPumps) => previousPumps,
      _ => null,
    };

    final result = await _repository.fetchPumpStatus(siteId: _siteId);

    switch (result) {
      case PumpRepositorySuccess(:final pumps):
        emit(PumpLoaded(pumps: pumps));

      case PumpRepositoryError(:final message, :final type):
        // On network errors: keep showing last good data + error banner
        // On parse errors: always show error screen (data is broken)
        if (type == PumpErrorType.parse) {
          emit(PumpError(
            message: message,
            type: type,
            previousPumps: null, // force full error screen
          ));
        } else {
          emit(PumpError(
            message: message,
            type: type,
            previousPumps: previousPumps, // keep showing stale cards
          ));
        }
    }
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────
  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _repository.dispose();
    return super.close();
  }
}
