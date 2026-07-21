// lib/core/error/failures.dart

/// Lớp cơ sở (Base class) cho tất cả các lỗi (Failure) trong ứng dụng.
/// Được sử dụng để truyền tải lỗi từ Data layer sang các lớp Domain và Presentation.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Lỗi xảy ra khi có sự cố từ server hoặc lỗi mạng
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Lỗi xảy ra khi không thể truy xuất dữ liệu trong cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Lỗi xảy ra do mất kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Lỗi xảy ra do dữ liệu xác thực không hợp lệ (Validation)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
