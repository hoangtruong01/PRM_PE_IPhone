// lib/core/error/exceptions.dart

/// Ngoại lệ ném ra khi yêu cầu từ máy chủ (server) thất bại
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Ngoại lệ ném ra khi thao tác bộ nhớ đệm (cache) thất bại
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Ngoại lệ ném ra khi không có kết nối mạng
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}
