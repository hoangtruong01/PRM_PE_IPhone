// lib/features/loan_request/domain/repositories/loan_request_repository.dart

import '../../../../core/utils/result.dart';
import '../entities/loan_request_entity.dart';

/// Repository Interface for loan requests (Domain Layer).
/// Defines the contract — implementation is in data layer.
abstract class LoanRequestRepository {
  /// Submit a loan request to the remote API
  Future<Result<Map<String, dynamic>>> submitLoanRequest({
    required LoanRequestEntity request,
    required String deviceName,
  });

  /// Save a loan request draft locally
  Future<Result<void>> saveDraft(LoanRequestEntity request);

  /// Load a saved draft
  Future<Result<LoanRequestEntity?>> loadDraft(String deviceId);

  /// Delete a saved draft
  Future<Result<void>> deleteDraft(String deviceId);
}
