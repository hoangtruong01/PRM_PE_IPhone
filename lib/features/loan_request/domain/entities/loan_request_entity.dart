// lib/features/loan_request/domain/entities/loan_request_entity.dart

/// Domain Entity: Represents a loan request in the business logic layer.
/// Pure Dart class — no framework dependencies.
class LoanRequestEntity {
  final String deviceId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String purpose;
  final double deposit;
  final String status;

  const LoanRequestEntity({
    required this.deviceId,
    required this.studentId,
    required this.borrowDate,
    required this.returnDate,
    required this.purpose,
    required this.deposit,
    this.status = 'pending',
  });

  /// Calculate loan period in days
  int get loanPeriodDays => returnDate.difference(borrowDate).inDays;

  /// Validation: loan period must not exceed 14 days
  bool get isValidLoanPeriod => loanPeriodDays > 0 && loanPeriodDays <= 14;

  /// Validation: borrow date must be today or later
  bool get isValidBorrowDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final borrow = DateTime(borrowDate.year, borrowDate.month, borrowDate.day);
    return !borrow.isBefore(today);
  }

  /// Validation: return date must be after borrow date
  bool get isValidReturnDate => returnDate.isAfter(borrowDate);

  @override
  String toString() =>
      'LoanRequestEntity(deviceId: $deviceId, studentId: $studentId, '
      'borrowDate: $borrowDate, returnDate: $returnDate)';
}
