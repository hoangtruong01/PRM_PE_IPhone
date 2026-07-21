// lib/features/loan_request/domain/entities/loan_result_entity.dart

/// Thực thể Domain (Domain Entity): Đại diện cho kết quả của yêu cầu mượn thành công.
/// Chứa các thông tin được trả về từ phản hồi của yêu cầu POST.
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

  /// Thời gian mượn thiết bị tính theo ngày
  int get loanPeriodDays => returnDate.difference(borrowDate).inDays;

  @override
  String toString() =>
      'LoanResultEntity(requestId: $requestId, deviceName: $deviceName)';
}
