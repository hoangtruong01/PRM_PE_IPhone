// lib/features/loan_request/domain/usecases/submit_loan_request_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/loan_request_entity.dart';
import '../repositories/loan_request_repository.dart';

/// UseCase: Gửi yêu cầu mượn thiết bị.
/// Xác thực yêu cầu trước khi gửi.
class SubmitLoanRequestUseCase {
  final LoanRequestRepository _repository;

  SubmitLoanRequestUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required LoanRequestEntity request,
    required String deviceName,
  }) {
    return _repository.submitLoanRequest(
      request: request,
      deviceName: deviceName,
    );
  }
}
