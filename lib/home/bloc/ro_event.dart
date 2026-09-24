import 'package:equatable/equatable.dart';

sealed class RoEvent extends Equatable {
  const RoEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when HomeScreen opens.
class LoadRoDetails extends RoEvent {
  const LoadRoDetails();
}

/// Fired when we need to load RO configuration.
class LoadRoConfig extends RoEvent {
  const LoadRoConfig();
}

/// Fired on Home load: probes /roconfig on every candidate IP and
/// picks the first one that responds.
class ProbeApi extends RoEvent {
  const ProbeApi();
}