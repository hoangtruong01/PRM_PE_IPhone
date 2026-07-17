// lib/core/network/network_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

/// A thin wrapper around http.Client for consistent error handling.
/// Widgets and use cases never call this directly — only DataSources do.
class NetworkClient {
  final http.Client _client;

  NetworkClient(this._client);

  /// Performs a GET request and returns decoded JSON
  Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          'Server responded with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  /// Performs a POST request and returns decoded JSON
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          'Server responded with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Network error: ${e.toString()}');
    }
  }
}
