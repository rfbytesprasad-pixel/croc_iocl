// lib/price_change/cubit/price_change_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/price_change_repository.dart';
import '../model/price_change_model.dart';
import 'price_change_state.dart';

class PriceChangeCubit extends Cubit<PriceChangeState> {
  final PriceChangeRepository _repository;

  PriceChangeCubit({required PriceChangeRepository repository})
      : _repository = repository,
        super(const PriceChangeInitial());

  // ── Called when user taps Submit ───────────────────────────────────────────
  Future<void> submitPriceChange({
    required String roCode,
    required int roAutoId,
    required int productAutoId,
    required double price,
    required DateTime effectiveFrom,
    required DateTime effectiveTo,
    required int updateBy,
  }) async {
    // Don't allow double submission
    if (state is PriceChangeSubmitting) return;

    emit(const PriceChangeSubmitting());

    final request = PriceChangeRequest(
      roCode: roCode,
      roAutoId: roAutoId,
      productAutoId: productAutoId,
      price: price,
      effectiveFrom: effectiveFrom,
      effectiveTo: effectiveTo,
      updateBy: updateBy,
    );

    final result = await _repository.submitPriceChange(request);

    switch (result) {
      case PriceChangeRepositorySuccess(:final response):
        emit(PriceChangeSubmitted(response: response));

      case PriceChangeRepositoryError(:final message):
        emit(PriceChangeError(message: message));
    }
  }

  // ── Reset form back to initial — called when user edits after submission ───
  void reset() => emit(const PriceChangeInitial());

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
