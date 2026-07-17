// lib/features/loan_request/data/repositories/loan_request_repository_impl.dart

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loan_request_entity.dart';
import '../../domain/repositories/loan_request_repository.dart';
import '../datasources/loan_request_local_datasource.dart';
import '../datasources/loan_request_remote_datasource.dart';
import '../models/loan_request_model.dart';

/// Repository Implementation for loan requests.
/// Coordinates between remote API and local storage.
/// Converts exceptions to Result types for clean error handling.
class LoanRequestRepositoryImpl implements LoanRequestRepository {
  final LoanRequestRemoteDataSource _remoteDataSource;
  final LoanRequestLocalDataSource _localDataSource;

  LoanRequestRepositoryImpl({
    required LoanRequestRemoteDataSource remoteDataSource,
    required LoanRequestLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<Map<String, dynamic>>> submitLoanRequest({
    required LoanRequestEntity request,
    required String deviceName,
  }) async {
    final model = LoanRequestModel.fromEntity(request);

    try {
      final response = await _remoteDataSource.submitLoanRequest(
        model,
        deviceName: deviceName,
      );

      // Clean up draft after successful submission
      try {
        await _localDataSource.deleteDraft(request.deviceId);
      } catch (_) {
        // Ignore draft cleanup errors
      }

      return Success(response);
    } on ServerException catch (e) {
      // Save as pending for retry
      try {
        await _localDataSource.savePendingRequest(model, deviceName);
      } catch (_) {
        // Ignore pending save errors
      }
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(ServerFailure('Failed to submit request: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> saveDraft(LoanRequestEntity request) async {
    try {
      final model = LoanRequestModel.fromEntity(request);
      await _localDataSource.saveDraft(model);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Failed to save draft: ${e.toString()}'));
    }
  }

  @override
  Future<Result<LoanRequestEntity?>> loadDraft(String deviceId) async {
    try {
      final model = _localDataSource.loadDraft(deviceId);
      return Success(model?.toEntity());
    } catch (e) {
      return Error(CacheFailure('Failed to load draft: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> deleteDraft(String deviceId) async {
    try {
      await _localDataSource.deleteDraft(deviceId);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Failed to delete draft: ${e.toString()}'));
    }
  }
}
