import '../model/ro_model.dart';
import '../model/ro_config_model.dart';
import '../../pump/data/pump_api_client.dart' hide NetworkException, ServerException, ParseException;
import 'ro_api_client.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Repository — the only layer the BLoC talks to.
/// ─────────────────────────────────────────────────────────────────────────────
class RoRepository {
  final RoApiClient _apiClient;

  RoRepository({
    required RoApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Probe /roconfig on every IP; returns the working base URL or null.
  Future<String?> probeRoConfig({required List<String> candidateIps}) {
    return _apiClient.probeRoConfig(candidateIps: candidateIps);
  }

  /// Swap the working IP after a successful probe.
  void setBaseUrl(String url) => _apiClient.baseUrl = url;

  /// Fallback: read roautoid from /pump when /roconfig is unavailable.
  /// Some ESPs (e.g. at the Gujarat site) don't serve /roconfig but do
  /// return roautoid on every /pump entry.
  Future<PumpRoCodeResult> fetchPumpRoCode() async {
    final client = PumpApiClient(baseUrl: _apiClient.baseUrl);
    try {
      final pumps = await client.getPumpStatus();
      if (pumps.isEmpty) {
  return PumpRoCodeError('No pumps returned from /pump');
} 
      return PumpRoCodeSuccess(pumps.first.roAutoId);
    } on NetworkException catch (e) {
      return PumpRoCodeError('Network : ${e.message}');
    } on ServerException catch (e) {
      return PumpRoCodeError('Server (${e.statusCode})');
    } on ParseException catch (e) {
      return PumpRoCodeError('Parse : ${e.message}');
    } catch (e) {
      return PumpRoCodeError('Unexpected : $e');
    } finally {
      client.dispose();
    }
  }

  /// /rodetails
  Future<RoRepositoryResult> fetchRoDetails() async {
    try {
      final ro = await _apiClient.getRoDetails();
      return RoRepositorySuccess(ro);
    } on NetworkException catch (e) {
      return RoRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: RoErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      // /rodetails may not be implemented on all ESPs. Treat 404 as
      // "no details available" and return an empty model so Home shows
      // a placeholder instead of a hard error.
      if (e.statusCode == 404) {
        return RoRepositorySuccess(RoModel.empty());
      }
      return RoRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: RoErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return RoRepositoryError(
        message: 'Unexpected data from server.',
        type: RoErrorType.parse,
        original: e,
      );
    } catch (e) {
      return RoRepositoryError(
        message: 'Something went wrong.',
        type: RoErrorType.unknown,
        original: e,
      );
    }
  }

  /// /roconfig
  Future<RoConfigRepositoryResult> fetchRoConfig() async {
    try {
      final config = await _apiClient.getRoConfig();
      return RoConfigRepositorySuccess(config);
    } on NetworkException catch (e) {
      return RoConfigRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: RoErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      return RoConfigRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: RoErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return RoConfigRepositoryError(
        message: 'Unexpected data from server.',
        type: RoErrorType.parse,
        original: e,
      );
    } catch (e) {
      return RoConfigRepositoryError(
        message: 'Something went wrong.',
        type: RoErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Result Types
/// ─────────────────────────────────────────────────────────────────────────────

sealed class RoRepositoryResult {}

class RoRepositorySuccess extends RoRepositoryResult {
  final RoModel ro;
  RoRepositorySuccess(this.ro);
}

class RoRepositoryError extends RoRepositoryResult {
  final String message;
  final RoErrorType type;
  final Object original;

  RoRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

sealed class RoConfigRepositoryResult {}

class RoConfigRepositorySuccess extends RoConfigRepositoryResult {
  final RoConfigModel config;
  RoConfigRepositorySuccess(this.config);
}

class RoConfigRepositoryError extends RoConfigRepositoryResult {
  final String message;
  final RoErrorType type;
  final Object original;

  RoConfigRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

sealed class PumpRoCodeResult {}

class PumpRoCodeSuccess extends PumpRoCodeResult {
  final int roCode;
  PumpRoCodeSuccess(this.roCode);
}

class PumpRoCodeError extends PumpRoCodeResult {
  final String message;
  PumpRoCodeError(this.message);
}

enum RoErrorType {
  network,
  server,
  parse,
  unknown,
}