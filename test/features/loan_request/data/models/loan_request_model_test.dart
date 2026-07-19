// test/features/loan_request/data/models/loan_request_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/features/loan_request/data/models/loan_request_model.dart';
import 'package:campus_equipment_loan/features/loan_request/domain/entities/loan_request_entity.dart';

void main() {
  group('LoanRequestModel', () {
    final testEntity = LoanRequestEntity(
      deviceId: '7',
      studentId: 'SE1819',
      borrowDate: DateTime(2026, 8, 1),
      returnDate: DateTime(2026, 8, 7),
      purpose: 'Mobile app demo',
      deposit: 50,
      status: 'pending',
    );

    group('fromEntity', () {
      test('should create model from entity', () {
        final model = LoanRequestModel.fromEntity(testEntity);

        expect(model.deviceId, '7');
        expect(model.studentId, 'SE1819');
        expect(model.purpose, 'Mobile app demo');
        expect(model.deposit, 50);
        expect(model.status, 'pending');
      });
    });

    group('toApiJson', () {
      test('should produce exact API format from exam spec', () {
        final model = LoanRequestModel.fromEntity(testEntity);
        final apiJson = model.toApiJson(deviceName: 'MacBook Pro 16');

        expect(apiJson['name'], 'Campus Equipment Loan Request');
        expect(apiJson['data'], isA<Map<String, dynamic>>());

        final data = apiJson['data'] as Map<String, dynamic>;
        expect(data['deviceId'], '7');
        expect(data['studentId'], 'SE1819');
        expect(data['borrowDate'], '2026-08-01');
        expect(data['returnDate'], '2026-08-07');
        expect(data['purpose'], 'Mobile app demo');
        expect(data['deposit'], 50);
        expect(data['status'], 'pending');
      });
    });

    group('toEntity', () {
      test('should convert back to entity correctly', () {
        final model = LoanRequestModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.deviceId, testEntity.deviceId);
        expect(entity.studentId, testEntity.studentId);
        expect(entity.purpose, testEntity.purpose);
        expect(entity.deposit, testEntity.deposit);
      });
    });

    group('JSON serialization', () {
      test('should serialize and deserialize correctly', () {
        final model = LoanRequestModel.fromEntity(testEntity);
        final jsonString = model.toJsonString();
        final restored = LoanRequestModel.fromJsonString(jsonString);

        expect(restored.deviceId, model.deviceId);
        expect(restored.studentId, model.studentId);
        expect(restored.purpose, model.purpose);
        expect(restored.deposit, model.deposit);
      });
    });
  });

  group('LoanRequestEntity', () {
    test('should calculate loan period correctly', () {
      final entity = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime(2026, 8, 1),
        returnDate: DateTime(2026, 8, 7),
        purpose: 'Demo',
        deposit: 50,
      );

      expect(entity.loanPeriodDays, 6);
    });

    test('should validate loan period <= 14 days', () {
      final valid = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime(2026, 8, 1),
        returnDate: DateTime(2026, 8, 15),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(valid.isValidLoanPeriod, true);

      final invalid = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime(2026, 8, 1),
        returnDate: DateTime(2026, 8, 20),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(invalid.isValidLoanPeriod, false);
    });

    test('should validate return date is after borrow date', () {
      final valid = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime(2026, 8, 1),
        returnDate: DateTime(2026, 8, 7),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(valid.isValidReturnDate, true);

      final invalid = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime(2026, 8, 7),
        returnDate: DateTime(2026, 8, 1),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(invalid.isValidReturnDate, false);
    });

    test('should reject borrow date in the past', () {
      final pastDate = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime.now().subtract(const Duration(days: 1)),
        returnDate: DateTime.now().add(const Duration(days: 6)),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(pastDate.isValidBorrowDate, false);

      final today = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime.now(),
        returnDate: DateTime.now().add(const Duration(days: 7)),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(today.isValidBorrowDate, true);

      final future = LoanRequestEntity(
        deviceId: '7',
        studentId: 'SE1819',
        borrowDate: DateTime.now().add(const Duration(days: 5)),
        returnDate: DateTime.now().add(const Duration(days: 12)),
        purpose: 'Demo',
        deposit: 50,
      );
      expect(future.isValidBorrowDate, true);
    });
  });
}
