// lib/price_change/data/price_change_repository.dart
import '../model/price_change_model.dart';
import 'price_change_api_client.dart';

// ── Repository — only layer Cubit talks to ────────────────────────────────────
class PriceChangeRepository {
  final PriceChangeApiClient _apiClient;

  PriceChangeRepository({required PriceChangeApiClient apiClient})
      : _apiClient = apiClient;

  Future<PriceChangeRepositoryResult> submitPriceChange(
      PriceChangeRequest request) async {
    try {
      final response = await _apiClient.postPriceChange(request);
      return PriceChangeRepositorySuccess(response);
    } on NetworkException catch (e) {
      return PriceChangeRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: PriceChangeErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      return PriceChangeRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: PriceChangeErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return PriceChangeRepositoryError(
        message: 'Unexpected response from server. Contact support.',
        type: PriceChangeErrorType.parse,
        original: e,
      );
    } catch (e) {
      return PriceChangeRepositoryError(
        message: 'Something went wrong. Please try again.',
        type: PriceChangeErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

// ── Result types — Cubit pattern matches on these ─────────────────────────────
sealed class PriceChangeRepositoryResult {}

class PriceChangeRepositorySuccess extends PriceChangeRepositoryResult {
  final PriceChangeResponse response;
  PriceChangeRepositorySuccess(this.response);
}

class PriceChangeRepositoryError extends PriceChangeRepositoryResult {
  final String message;
  final PriceChangeErrorType type;
  final Object original;

  PriceChangeRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

enum PriceChangeErrorType { network, server, parse, unknown }
