// lib/pump/bloc/pump_event.dart
import 'package:equatable/equatable.dart';

sealed class PumpEvent extends Equatable {
  const PumpEvent();

  @override
  List<Object?> get props => [];
}

// ── User enters Pumps tab → start polling ─────────────────────────────────────
// Fired by PumpScreen in initState
// BLoC reacts: fetch immediately + start 10s timer
class PumpStartPolling extends PumpEvent {
  final String? siteId; // optional, pass null to get all pumps

  const PumpStartPolling({this.siteId});

  @override
  List<Object?> get props => [siteId];
}

// ── User leaves Pumps tab → stop polling ──────────────────────────────────────
// Fired by PumpScreen in dispose()
// BLoC reacts: cancel timer, no more fetches
class PumpStopPolling extends PumpEvent {
  const PumpStopPolling();
}

// ── Internal event — fired by the timer every 10s ─────────────────────────────
// Never fired from UI directly
// BLoC reacts: call repository, emit PumpLoaded or PumpError
class PumpTimerTicked extends PumpEvent {
  const PumpTimerTicked();
}
