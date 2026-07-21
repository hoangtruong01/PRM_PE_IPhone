// lib/features/loan_request/domain/entities/loan_request_entity.dart

/// Thực thể Domain (Domain Entity): Đại diện cho yêu cầu mượn thiết bị trong lớp logic nghiệp vụ.
/// Lớp Dart thuần túy — không phụ thuộc vào framework.
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

  /// Tính số ngày mượn thiết bị
  int get loanPeriodDays => returnDate.difference(borrowDate).inDays;

  /// Xác thực: Thời hạn mượn không vượt quá 14 ngày
  bool get isValidLoanPeriod => loanPeriodDays > 0 && loanPeriodDays <= 14;

  /// Xác thực: Ngày bắt đầu mượn phải từ ngày hôm nay trở đi
  bool get isValidBorrowDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final borrow = DateTime(borrowDate.year, borrowDate.month, borrowDate.day);
    return !borrow.isBefore(today);
  }

  /// Xác thực: Ngày trả thiết bị phải sau ngày mượn
  bool get isValidReturnDate => returnDate.isAfter(borrowDate);

  @override
  String toString() =>
      'LoanRequestEntity(deviceId: $deviceId, studentId: $studentId, '
      'borrowDate: $borrowDate, returnDate: $returnDate)';
}
