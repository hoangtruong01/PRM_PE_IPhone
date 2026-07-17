// lib/features/loan_request/domain/usecases/delete_draft_usecase.dart

import '../../../../core/utils/result.dart';
import '../repositories/loan_request_repository.dart';

class DeleteDraftUseCase {
  final LoanRequestRepository _repository;

  DeleteDraftUseCase(this._repository);

  Future<Result<void>> call(String deviceId) {
    return _repository.deleteDraft(deviceId);
  }
}
