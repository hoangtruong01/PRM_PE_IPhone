// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.restful-api.dev';
  static const String objectsEndpoint = '/objects';

  /// GET all devices
  static String get devicesUrl => '$baseUrl$objectsEndpoint';

  /// GET single device by id
  static String deviceByIdUrl(String id) => '$baseUrl$objectsEndpoint/$id';

  /// POST loan request
  static String get loanRequestUrl => '$baseUrl$objectsEndpoint';
}
