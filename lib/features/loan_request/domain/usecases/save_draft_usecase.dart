// lib/features/loan_request/domain/usecases/save_draft_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/loan_request_entity.dart';
import '../repositories/loan_request_repository.dart';

class SaveDraftUseCase {
  final LoanRequestRepository _repository;

  SaveDraftUseCase(this._repository);

  Future<Result<void>> call(LoanRequestEntity request) {
    return _repository.saveDraft(request);
  }
}
