// lib/preset/cubit/preset_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/preset_repository.dart';
import '../model/preset_model.dart';
import 'preset_state.dart';

class PresetCubit extends Cubit<PresetState> {
  final PresetRepository _repository;

  PresetCubit({required PresetRepository repository})
      : _repository = repository,
        super(const PresetInitial());

  Future<void> submitPreset({
    required int roAutoId,
    required int duid,
    required int pumpAutoId,
    required int nozzleAutoId,
    required PresetOperation operationId,
    required PresetMode presetMode,
    required PresetMop presetMop,
    required String presetValue,
    required int updateBy,
  }) async {
    if (state is PresetSubmitting) return;

    emit(const PresetSubmitting());

    final request = PresetRequest(
      roAutoId: roAutoId,
      duid: duid,
      pumpAutoId: pumpAutoId,
      nozzleAutoId: nozzleAutoId,
      operationId: operationId,
      presetMode: presetMode,
      presetMop: presetMop,
      presetValue: presetValue,
      updateBy: updateBy,
    );

    final result = await _repository.submitPreset(request);
    if (isClosed) return;
    switch (result) {
      case PresetRepositorySuccess(:final response):
        emit(PresetSubmitted(response: response));
      case PresetRepositoryError(:final message):
        emit(PresetError(message: message));
    }
  }

  void reset() => emit(const PresetInitial());

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}