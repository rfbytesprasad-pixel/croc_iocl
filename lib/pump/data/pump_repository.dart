// lib/pump/data/pump_repository.dart
import '../model/pump_status_model.dart';
import 'pump_api_client.dart';

// ── Repository — only layer BLoC talks to ─────────────────────────────────────
class PumpRepository {
  final PumpApiClient _apiClient;

  PumpRepository({required PumpApiClient apiClient}) : _apiClient = apiClient;

  // ── Fetch pump status — converts API exceptions to domain results ──────────
  Future<PumpRepositoryResult> fetchPumpStatus({String? siteId}) async {
    try {
      final pumps = await _apiClient.getPumpStatus(siteId: siteId);
      print("pumps that we are getting ${pumps.length}");
      return PumpRepositorySuccess(pumps);
    } on NetworkException catch (e) {
      return PumpRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: PumpErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      return PumpRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: PumpErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return PumpRepositoryError(
        message: 'Unexpected data from server. Contact support.',
        type: PumpErrorType.parse,
        original: e,
      );
    } catch (e) {
      return PumpRepositoryError(
        message: 'Something went wrong. Please try again.',
        type: PumpErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

// ── Result types — BLoC pattern matches on these ───────────────────────────────
sealed class PumpRepositoryResult {}

class PumpRepositorySuccess extends PumpRepositoryResult {
  final List<PumpStatusModel> pumps;
  PumpRepositorySuccess(this.pumps);
}

class PumpRepositoryError extends PumpRepositoryResult {
  final String message; // human-readable, shown in UI
  final PumpErrorType type; // BLoC uses this to decide retry logic
  final Object original; // original exception, useful for logging later

  PumpRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

enum PumpErrorType { network, server, parse, unknown }
