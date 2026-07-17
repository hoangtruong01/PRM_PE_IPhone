// test/core/utils/result_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/core/error/failures.dart';
import 'package:campus_equipment_loan/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Success should hold data', () {
      const result = Success<String>('hello');
      expect(result.data, 'hello');
    });

    test('Error should hold failure', () {
      const result = Error<String>(ServerFailure('oops'));
      expect(result.failure.message, 'oops');
    });

    test('should work with switch pattern matching', () {
      final Result<int> result = const Success(42);

      final output = switch (result) {
        Success<int>(:final data) => 'Got $data',
        Error<int>(:final failure) => 'Error: ${failure.message}',
      };

      expect(output, 'Got 42');
    });

    test('should work with Error pattern matching', () {
      final Result<int> result =
          const Error(ServerFailure('not found', statusCode: 404));

      final output = switch (result) {
        Success<int>() => 'success',
        Error<int>(:final failure) => failure.message,
      };

      expect(output, 'not found');
    });
  });
}
