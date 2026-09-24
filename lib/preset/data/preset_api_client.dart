// lib/preset/data/preset_api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/preset_model.dart';

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

class PresetApiClient {
  final http.Client _client;
  final String baseUrl;

  PresetApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<PresetResponse> postPreset(PresetRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/preset');
      final body = jsonEncode(request.toJson());

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw const NetworkException('Request timed out'),
          );

      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return PresetResponse.fromJson(decoded);
        }
        if (decoded is int) {
          return PresetResponse.fromJson({'status': decoded});
        }
        if (decoded is String) {
          return PresetResponse.fromJson({'status': decoded});
        }

        throw const ParseException('Unexpected response format');
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
