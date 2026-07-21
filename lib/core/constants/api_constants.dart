// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.restful-api.dev';
  static const String objectsEndpoint = '/objects';

  /// Lấy tất cả thiết bị (GET)
  static String get devicesUrl => '$baseUrl$objectsEndpoint';

  /// Lấy chi tiết một thiết bị theo ID (GET)
  static String deviceByIdUrl(String id) => '$baseUrl$objectsEndpoint/$id';

  /// Gửi yêu cầu mượn thiết bị (POST)
  static String get loanRequestUrl => '$baseUrl$objectsEndpoint';
}
