// lib/pump/bloc/pump_state.dart
import 'package:croc_iocl_atos/pump/data/pump_repository.dart';
import 'package:equatable/equatable.dart';
import '../model/pump_status_model.dart';

sealed class PumpState extends Equatable {
  const PumpState();

  @override
  List<Object?> get props => [];
}

// ── App just opened, BLoC created, nothing fetched yet ────────────────────────
// UI shows: nothing / empty shell
class PumpInitial extends PumpState {
  const PumpInitial();
}

// ── First ever fetch is in progress ───────────────────────────────────────────
// UI shows: shimmer / skeleton cards
// Only emitted ONCE — on first load
// Background polls after this never show loading again
class PumpLoading extends PumpState {
  const PumpLoading();
}

// ── Data successfully fetched ─────────────────────────────────────────────────
// UI shows: pump cards grid
// Emitted on first load AND every background poll
class PumpLoaded extends PumpState {
  final List<PumpStatusModel> pumps;
  final bool isRefreshing; // true during background poll, false on first load

  const PumpLoaded({
    required this.pumps,
    this.isRefreshing = false,
  });

  // Creates a copy with isRefreshing toggled — used during background polls
  PumpLoaded copyWith({
    List<PumpStatusModel>? pumps,
    bool? isRefreshing,
  }) {
    return PumpLoaded(
      pumps: pumps ?? this.pumps,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [pumps, isRefreshing];
}

// ── Something went wrong ───────────────────────────────────────────────────────
// UI shows: error message + retry button
// previousPumps keeps last known good data so UI doesn't go blank on error
class PumpError extends PumpState {
  final String message;
  final PumpErrorType type;
  final List<PumpStatusModel>? previousPumps; // last good data, may be null

  const PumpError({
    required this.message,
    required this.type,
    this.previousPumps,
  });

  bool get hasPreviousData =>
      previousPumps != null && previousPumps!.isNotEmpty;

  @override
  List<Object?> get props => [message, type, previousPumps];
}
