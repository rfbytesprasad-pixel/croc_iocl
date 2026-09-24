import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/pump_status_model.dart';

// ── Typed exceptions — BLoC will catch these specifically ──────────────────────
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

// ── API Client — only knows about HTTP, nothing else ──────────────────────────
class PumpApiClient {
  final http.Client _client;
  final String baseUrl;

  PumpApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ── GET /pump ──────────────────────────────────────────────────────────────
  Future<List<PumpStatusModel>> getPumpStatus({String? siteId}) async {
    try {
      // Build URI with optional siteId query param
      final uri = Uri.parse('$baseUrl/pump').replace(
        queryParameters: siteId != null ? {'siteId': siteId} : null,
      );

      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'}).timeout(
        const Duration(seconds: 8), // fail before next 10s poll starts
        onTimeout: () => throw const NetworkException('Request timed out'),
      );
      print("reponse ${response.body}");
      // ── Handle HTTP error codes ──────────────────────────────────────────
      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      // ── Parse JSON ────────────────────────────────────────────────────────
      // try {
      //   final decoded = jsonDecode(response.body);

      //   // API may return a single object or a list — handle both
      //   if (decoded is List) {
      //     return decoded
      //         .map((item) =>
      //             PumpStatusModel.fromJson(item as Map<String, dynamic>))
      //         .toList();
      //   } else if (decoded is Map<String, dynamic>) {
      //     return [PumpStatusModel.fromJson(decoded)];
      //   } else {
      //     throw const ParseException('Unexpected JSON format');
      //   }
      // } catch (e) {
      //   if (e is ParseException) rethrow;
      //   throw ParseException('Failed to parse response: $e');
      // }

      // ── Parse JSON ────────────────────────────────────────────────────────
      try {
        final decoded = jsonDecode(response.body);

        // Shape: { "pumpstatus": [ {}, {}, {} ] }  ← your actual API
        if (decoded is Map<String, dynamic> && decoded['pumpstatus'] is List) {
          final list = decoded['pumpstatus'] as List;
          return list
              .map((item) => PumpStatusModel.fromJson({
                    'pumpstatus': item, // ← wrap each item so fromJson works
                  }))
              .toList();
        }

        // Shape: [ {}, {}, {} ]  ← flat list fallback
        else if (decoded is List) {
          return decoded
              .map((item) =>
                  PumpStatusModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // Shape: { "pumpstatus": {} }  ← single object fallback
        else if (decoded is Map<String, dynamic>) {
          return [PumpStatusModel.fromJson(decoded)];
        } else {
          throw const ParseException('Unexpected JSON format');
        }
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException('Failed to parse response: $e');
      }
    } on NetworkException {
      rethrow; // already typed, let BLoC handle it
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

  // ── Call this when BLoC is closed ─────────────────────────────────────────
  void dispose() => _client.close();
}
