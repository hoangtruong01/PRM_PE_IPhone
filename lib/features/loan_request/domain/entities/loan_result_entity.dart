// lib/features/loan_request/domain/entities/loan_result_entity.dart

/// Domain Entity: Represents the result of a successful loan request.
/// Contains the data returned from the POST response.
class LoanResultEntity {
  final String requestId;
  final String deviceName;
  final DateTime borrowDate;
  final DateTime returnDate;
  final double deposit;
  final String status;
  final DateTime createdAt;

  const LoanResultEntity({
    required this.requestId,
    required this.deviceName,
    required this.borrowDate,
    required this.returnDate,
    required this.deposit,
    required this.status,
    required this.createdAt,
  });

  /// Loan period in days
  int get loanPeriodDays => returnDate.difference(borrowDate).inDays;

  @override
  String toString() =>
      'LoanResultEntity(requestId: $requestId, deviceName: $deviceName)';
}
