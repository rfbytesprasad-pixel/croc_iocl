import 'package:croc_iocl_atos/tank/data/tank_api_client.dart';
import 'package:croc_iocl_atos/tank/model/tank_status_model.dart';

class TankRepository {
  final TankApiClient _apiClient;

  TankRepository({required TankApiClient apiClient}) : _apiClient = apiClient;

  Future<TankRepositoryResult> fetchTankStatus({String? siteId}) async {
    try {
      final tanks = await _apiClient.getTankStatus(siteId: siteId);
      return TankRepositorySuccess(tanks);
    } on NetworkException catch (e) {
      return TankRepositoryError(
          message: 'No internet connection. Please check your network.',
          type: TankErrorType.network,
          original: e);
    } on ServerException catch (e) {
      return TankRepositoryError(
        message: 'Server error (${e.statusCode}). Please try again.',
        type: TankErrorType.server,
        original: e,
      );
    } on ParseException catch (e) {
      return TankRepositoryError(
        message: 'Unexpected data from server. Contact support.',
        type: TankErrorType.parse,
        original: e,
      );
    } catch (e) {
      return TankRepositoryError(
        message: 'Something went wrong. Please try again.',
        type: TankErrorType.unknown,
        original: e,
      );
    }
  }

  void dispose() => _apiClient.dispose();
}

sealed class TankRepositoryResult {}

class TankRepositorySuccess extends TankRepositoryResult {
  final List<TankStatusModel> tanks;
  TankRepositorySuccess(this.tanks);
}

class TankRepositoryError extends TankRepositoryResult {
  final String message;
  final TankErrorType type;
  final Object original;

  TankRepositoryError(
      {required this.message, required this.type, required this.original});
}

enum TankErrorType { network, server, parse, unknown }
