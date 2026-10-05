// lib/density/cubit/density_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/density_repository.dart';
import '../model/density_model.dart';
import 'density_state.dart';

class DensityCubit extends Cubit<DensityState> {
  final DensityRepository _repository;

  DensityCubit({required DensityRepository repository})
      : _repository = repository,
        super(const DensityInitial());

  Future<void> submitDensityChange({
    required int roAutoId,
    required int tankAutoId,
    required int productId,
    required double density,
    required int updateBy,
  }) async {
    if (state is DensitySubmitting) return;

    emit(const DensitySubmitting());

    final request = DensityRequest(
      roAutoId: roAutoId,
      tankAutoId: tankAutoId,
      productId: productId,
      density: density,
      updateBy: updateBy,
    );

    final result = await _repository.submitDensityChange(request);
    if (isClosed) return;

    switch (result) {
      case DensityRepositorySuccess(:final response):
        emit(DensitySubmitted(response: response));
      case DensityRepositoryError(:final message):
        emit(DensityError(message: message));
    }
  }

  void reset() => emit(const DensityInitial());

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}