import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/ro_model.dart';
import '../model/ro_config_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Exceptions
/// ─────────────────────────────────────────────────────────────────────────────

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

/// ─────────────────────────────────────────────────────────────────────────────
/// API Client
/// ─────────────────────────────────────────────────────────────────────────────

class RoApiClient {
  final http.Client _client;

  /// Mutable so [probeRoConfig] can swap the working IP at runtime.
  String baseUrl;

  RoApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ───────────────────────────────────────────────────────────────────────────
  // Probe: try /roconfig on every candidate IP in parallel, return first hit.
  // ───────────────────────────────────────────────────────────────────────────
  Future<String?> probeRoConfig({
    required List<String> candidateIps,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final futures = candidateIps.map((ip) async {
      final url = 'http://$ip/roconfig';
      try {
        final response = await _client
            .get(Uri.parse(url),
                headers: const {'Content-Type': 'application/json'})
            .timeout(timeout);

        debugPrint('Probe $url → ${response.statusCode}');

        if (response.statusCode == 200) {
          return url.substring(0, url.length - '/roconfig'.length);
        }
      } catch (e) {
        debugPrint('Probe $url → failed: $e');
      }
      return null;
    }).toList();

    // Race: whichever succeeds first wins.
    final results = await Future.wait(futures);
    for (final r in results) {
      if (r != null) return r;
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /rodetails
  // ───────────────────────────────────────────────────────────────────────────
  Future<RoModel> getRoDetails() async {
    try {
      final uri = Uri.parse('$baseUrl/rodetails');

      final response = await _client.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw const NetworkException('Request timed out'),
      );

      debugPrint('RO Details Response : ${response.body}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return RoModel.fromJson(decoded);
        }
        throw const ParseException('Unexpected JSON format');
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException('Failed to parse response : $e');
      }
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('No internet connection : ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error : ${e.message}');
    } catch (e) {
      throw NetworkException('Unexpected error : $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GET /roconfig
  // ───────────────────────────────────────────────────────────────────────────
  Future<RoConfigModel> getRoConfig() async {
    try {
      final uri = Uri.parse('$baseUrl/roconfig');

      final response = await _client.get(
        uri,
        headers: const {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw const NetworkException('Request timed out'),
      );

      debugPrint('RO Config Response : ${response.body}');

      if (response.statusCode != 200) {
        throw ServerException(
          response.statusCode,
          'Server returned ${response.statusCode}',
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return RoConfigModel.fromJson(decoded);
        }
        throw const ParseException('Unexpected JSON format');
      } catch (e) {
        if (e is ParseException) rethrow;
        throw ParseException('Failed to parse response : $e');
      }
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('No internet connection : ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error : ${e.message}');
    } catch (e) {
      throw NetworkException('Unexpected error : $e');
    }
  }

  void dispose() => _client.close();
}