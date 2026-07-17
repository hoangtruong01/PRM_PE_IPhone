// lib/features/loan_request/domain/usecases/load_draft_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/loan_request_entity.dart';
import '../repositories/loan_request_repository.dart';

class LoadDraftUseCase {
  final LoanRequestRepository _repository;

  LoadDraftUseCase(this._repository);

  Future<Result<LoanRequestEntity?>> call(String deviceId) {
    return _repository.loadDraft(deviceId);
  }
}
