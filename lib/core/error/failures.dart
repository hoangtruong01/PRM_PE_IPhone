// lib/core/error/failures.dart

/// Base class for all failures in the application.
/// Used to communicate errors from data layer to domain/presentation layers.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Failure when a server/network error occurs
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Failure when cached data is not available
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
