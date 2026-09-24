import 'package:equatable/equatable.dart';

import '../data/ro_repository.dart';
import '../model/ro_model.dart';

/// States that represent what the Home screen is currently showing.
///
/// RO config is deliberately NOT here — it is background reference data
/// stored on [RoBloc] and read via `context.read<RoBloc>().roConfig`.
sealed class RoState extends Equatable {
  const RoState();

  @override
  List<Object?> get props => [];
}

class RoInitial extends RoState {
  const RoInitial();
}

/// API probe is running — trying all candidate IPs.
class RoApiProbing extends RoState {
  const RoApiProbing();
}

/// API probe failed on every candidate IP. Show "API not configured".
class RoApiNotConfigured extends RoState {
  const RoApiNotConfigured();
}

/// `/rodetails` is in flight.
class RoLoading extends RoState {
  const RoLoading();
}

/// `/rodetails` succeeded.
class RoLoaded extends RoState {
  final RoModel ro;

  const RoLoaded({required this.ro});

  @override
  List<Object?> get props => [ro];
}

/// `/rodetails` failed.
class RoError extends RoState {
  final String message;
  final RoErrorType type;

  const RoError({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}