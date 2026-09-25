// lib/tank/data/tank_api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:croc_iocl_atos/core/constants.dart';
import 'package:croc_iocl_atos/tank/model/tank_status_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final int statusCode;
  final String message;
  const ServerException(this.statusCode, this.message);
  @override
  String toString() => 'ServerException($statusCode): $message';
}

class ParseException implements Exception {
  final String message;
  const ParseException(this.message);
  @override
  String toString() => 'ParseException: $message';
}

class TankApiClient {
  final http.Client _client;

  /// baseUrl is read fresh from [AppConstants.baseUrl] on every request,
  /// so the probed IP is used even if this client was constructed before
  /// the probe completed.
  TankApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<TankStatusModel>> getTankStatus({String? siteId}) async {
    final baseUrl = AppConstants.baseUrl;
    try {
      final uri = Uri.parse('$baseUrl/tankstatus').replace(
        queryParameters: siteId != null ? {'siteId': siteId} : null,
      );

      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'}).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw const NetworkException('Request timed out'),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      debugPrint('Tank response: ${response.body}');

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => TankStatusModel.fromJson(item))
              .toList();
        }

        if (decoded is Map<String, dynamic>) {
          return [TankStatusModel.fromJson(decoded)];
        }

        throw const ParseException('Unexpected JSON format');
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException('Failed to parse response: $e');
      }
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('No internet connection: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  void dispose() => _client.close();
}