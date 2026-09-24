// lib/price_change/data/price_change_api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/price_change_model.dart';

// ── Typed exceptions — same pattern as pump/tank ──────────────────────────────
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

// ── API Client — only knows about HTTP ────────────────────────────────────────
class PriceChangeApiClient {
  final http.Client _client;
  final String baseUrl;

  PriceChangeApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ── POST /pricechange ──────────────────────────────────────────────────────
  Future<PriceChangeResponse> postPriceChange(
      PriceChangeRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/pricechange');
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

      // ── Handle HTTP errors ───────────────────────────────────────────
      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      // ── Parse response ───────────────────────────────────────────────
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return PriceChangeResponse.fromJson(decoded);
        }

        // Some APIs return just a status code integer
        if (decoded is int) {
          return PriceChangeResponse.fromJson({'status': decoded});
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
