// lib/core/network/network_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

/// Lớp bọc ngoài http.Client để xử lý lỗi một cách thống nhất.
/// Widget và UseCase không bao giờ gọi trực tiếp lớp này — chỉ các DataSource mới sử dụng nó.
class NetworkClient {
  final http.Client _client;

  NetworkClient(this._client);

  /// Thực hiện yêu cầu GET và trả về JSON đã được giải mã
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

  /// Thực hiện yêu cầu POST và trả về JSON đã được giải mã
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
