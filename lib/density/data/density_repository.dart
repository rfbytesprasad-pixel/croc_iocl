// lib/density/data/density_repository.dart
import '../model/density_model.dart';
import 'density_api_client.dart';

class DensityRepository {
  final DensityApiClient _apiClient;

  DensityRepository({required DensityApiClient apiClient})
      : _apiClient = apiClient;

  Future<DensityRepositoryResult> submitDensityChange(
      DensityRequest request) async {
    try {
      final response = await _apiClient.postDensityChange(request);
      return DensityRepositorySuccess(response);
    } on NetworkException catch (e) {
      return DensityRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: DensityErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      return DensityRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: DensityErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return DensityRepositoryError(
        message: 'Unexpected response from server. Contact support.',
        type: DensityErrorType.parse,
        original: e,
      );
    } catch (e) {
      return DensityRepositoryError(
        message: 'Something went wrong. Please try again.',
        type: DensityErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

sealed class DensityRepositoryResult {}

class DensityRepositorySuccess extends DensityRepositoryResult {
  final DensityResponse response;
  DensityRepositorySuccess(this.response);
}

class DensityRepositoryError extends DensityRepositoryResult {
  final String message;
  final DensityErrorType type;
  final Object original;

  DensityRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

enum DensityErrorType { network, server, parse, unknown }