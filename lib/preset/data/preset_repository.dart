// lib/preset/data/preset_repository.dart
import '../model/preset_model.dart';
import 'preset_api_client.dart';

class PresetRepository {
  final PresetApiClient _apiClient;

  PresetRepository({required PresetApiClient apiClient})
      : _apiClient = apiClient;

  Future<PresetRepositoryResult> submitPreset(PresetRequest request) async {
    try {
      final response = await _apiClient.postPreset(request);
      return PresetRepositorySuccess(response);
    } on NetworkException catch (e) {
      return PresetRepositoryError(
        message: 'No internet connection. Please check your network.',
        type: PresetErrorType.network,
        original: e,
      );
    } on ServerException catch (e) {
      return PresetRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: PresetErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return PresetRepositoryError(
        message: 'Unexpected response from server. Contact support.',
        type: PresetErrorType.parse,
        original: e,
      );
    } catch (e) {
      return PresetRepositoryError(
        message: 'Something went wrong. Please try again.',
        type: PresetErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

sealed class PresetRepositoryResult {}

class PresetRepositorySuccess extends PresetRepositoryResult {
  final PresetResponse response;
  PresetRepositorySuccess(this.response);
}

class PresetRepositoryError extends PresetRepositoryResult {
  final String message;
  final PresetErrorType type;
  final Object original;

  PresetRepositoryError({
    required this.message,
    required this.type,
    required this.original,
  });
}

enum PresetErrorType { network, server, parse, unknown }
