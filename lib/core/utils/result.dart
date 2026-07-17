// lib/core/utils/result.dart

/// A generic Result type for clean error handling without exceptions.
/// Used by repositories to return either success data or a Failure.
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
