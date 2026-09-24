import 'package:equatable/equatable.dart';

sealed class TankEvent extends Equatable {
  const TankEvent();

  @override
  List<Object?> get props => [];
}

class TankStartPolling extends TankEvent {
  final String? siteId;
  const TankStartPolling({this.siteId});

  @override
  List<Object?> get props => [siteId];
}

class TankStopPolling extends TankEvent {
  const TankStopPolling();
}

class TankTimerTicked extends TankEvent {
  const TankTimerTicked();
}
