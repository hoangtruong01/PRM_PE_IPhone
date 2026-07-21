// lib/core/utils/result.dart

/// Kiểu dữ liệu Result tổng quát (generic) để xử lý lỗi sạch sẽ mà không cần ném ngoại lệ (exception).
/// Được các Repository sử dụng để trả về dữ liệu thành công (Success) hoặc lỗi (Failure).
import '../error/failures.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
