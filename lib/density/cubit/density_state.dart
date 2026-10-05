// lib/density/cubit/density_state.dart
import 'package:equatable/equatable.dart';

import '../model/density_model.dart';

sealed class DensityState extends Equatable {
  const DensityState();
  @override
  List<Object?> get props => [];
}

class DensityInitial extends DensityState {
  const DensityInitial();
}

class DensitySubmitting extends DensityState {
  const DensitySubmitting();
}

class DensitySubmitted extends DensityState {
  final DensityResponse response;

  const DensitySubmitted({required this.response});

  bool get isSuccess =>
      response.status == DensityResponseStatus.success;
  bool get isPending =>
      response.status == DensityResponseStatus.pending;
  bool get isFailure =>
      response.status == DensityResponseStatus.failure;

  @override
  List<Object?> get props => [response];
}

class DensityError extends DensityState {
  final String message;

  const DensityError({required this.message});

  @override
  List<Object?> get props => [message];
}