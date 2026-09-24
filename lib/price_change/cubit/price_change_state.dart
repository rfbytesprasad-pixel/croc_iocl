// lib/price_change/cubit/price_change_state.dart
import 'package:equatable/equatable.dart';
import '../model/price_change_model.dart';

sealed class PriceChangeState extends Equatable {
  const PriceChangeState();

  @override
  List<Object?> get props => [];
}

// ── Form is empty and ready to fill ───────────────────────────────────────────
class PriceChangeInitial extends PriceChangeState {
  const PriceChangeInitial();
}

// ── POST in flight — disable submit button, show spinner ──────────────────────
class PriceChangeSubmitting extends PriceChangeState {
  const PriceChangeSubmitting();
}

// ── HTTP 200 received — but check response.status for pending vs success ───────
class PriceChangeSubmitted extends PriceChangeState {
  final PriceChangeResponse response;

  const PriceChangeSubmitted({required this.response});

  // ── Convenience getters for UI ─────────────────────────────────────────────
  bool get isSuccess => response.status == PriceChangeResponseStatus.success;

  bool get isPending => response.status == PriceChangeResponseStatus.pending;

  @override
  List<Object?> get props => [response.status, response.displayMessage];
}

// ── Network/server/parse error ─────────────────────────────────────────────────
class PriceChangeError extends PriceChangeState {
  final String message;

  const PriceChangeError({required this.message});

  @override
  List<Object?> get props => [message];
}
