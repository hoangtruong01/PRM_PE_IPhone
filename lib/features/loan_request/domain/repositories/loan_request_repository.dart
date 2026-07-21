// lib/features/loan_request/domain/repositories/loan_request_repository.dart

import '../../../../core/utils/result.dart';
import '../entities/loan_request_entity.dart';

/// Giao diện Repository cho các yêu cầu mượn thiết bị (Domain Layer).
/// Định nghĩa hợp đồng (contract) — phần triển khai nằm ở lớp Data.
abstract class LoanRequestRepository {
  /// Gửi yêu cầu mượn thiết bị lên remote API
  Future<Result<Map<String, dynamic>>> submitLoanRequest({
    required LoanRequestEntity request,
    required String deviceName,
  });

  /// Lưu bản nháp yêu cầu mượn cục bộ
  Future<Result<void>> saveDraft(LoanRequestEntity request);

  /// Tải bản nháp đã lưu
  Future<Result<LoanRequestEntity?>> loadDraft(String deviceId);

  /// Xóa bản nháp đã lưu
  Future<Result<void>> deleteDraft(String deviceId);
}
