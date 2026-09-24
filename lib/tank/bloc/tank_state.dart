import 'package:croc_iocl_atos/tank/data/tank_repository.dart';
import 'package:croc_iocl_atos/tank/model/tank_status_model.dart';
import 'package:equatable/equatable.dart';

sealed class TankState extends Equatable {
  const TankState();
  @override
  List<Object?> get props => [];
}

class TankInitial extends TankState {
  const TankInitial();
}

class TankLoading extends TankState {
  const TankLoading();
}

class TankLoaded extends TankState {
  final List<TankStatusModel> tanks;
  final bool isRefreshing;

  const TankLoaded({
    required this.tanks,
    this.isRefreshing = false,
  });

  TankLoaded copyWith({
    List<TankStatusModel>? tanks,
    bool? isRefreshing,
  }) {
    return TankLoaded(
        tanks: tanks ?? this.tanks,
        isRefreshing: isRefreshing ?? this.isRefreshing);
  }

  @override
  List<Object?> get props => [tanks, isRefreshing];
}

class TankError extends TankState {
  final String message;
  final TankErrorType type;
  final List<TankStatusModel>? previoustanks;

  const TankError(
      {required this.message, required this.type, this.previoustanks});

  bool get hasPreviousData =>
      previoustanks != null && previoustanks!.isNotEmpty;

  @override
  List<Object?> get props => [message, type, previoustanks];
}
