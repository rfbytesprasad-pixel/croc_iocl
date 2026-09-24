// lib/preset/cubit/preset_state.dart
import 'package:equatable/equatable.dart';
import '../model/preset_model.dart';

sealed class PresetState extends Equatable {
  const PresetState();

  @override
  List<Object?> get props => [];
}

class PresetInitial extends PresetState {
  const PresetInitial();
}

class PresetSubmitting extends PresetState {
  const PresetSubmitting();
}

class PresetSubmitted extends PresetState {
  final PresetResponse response;

  const PresetSubmitted({required this.response});

  bool get isSuccess => response.status == PresetResponseStatus.success;

  bool get isPending => response.status == PresetResponseStatus.pending;

  bool get isFailure => response.status == PresetResponseStatus.failure;

  @override
  List<Object?> get props => [response.status, response.displayMessage];
}

class PresetError extends PresetState {
  final String message;

  const PresetError({required this.message});

  @override
  List<Object?> get props => [message];
}
