// lib/features/loan_request/data/datasources/loan_request_remote_datasource.dart

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/loan_request_model.dart';

/// Remote DataSource for loan requests.
/// Handles the POST request to submit a loan request.
abstract class LoanRequestRemoteDataSource {
  /// Submit a loan request to the API
  /// Returns the raw response JSON containing id, createdAt, etc.
  Future<Map<String, dynamic>> submitLoanRequest(
    LoanRequestModel request, {
    required String deviceName,
  });
}

class LoanRequestRemoteDataSourceImpl implements LoanRequestRemoteDataSource {
  final NetworkClient _networkClient;

  LoanRequestRemoteDataSourceImpl(this._networkClient);

  @override
  Future<Map<String, dynamic>> submitLoanRequest(
    LoanRequestModel request, {
    required String deviceName,
  }) async {
    try {
      final body = request.toApiJson(deviceName: deviceName);
      final response =
          await _networkClient.post(ApiConstants.loanRequestUrl, body);

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw const ServerException(
          'Invalid response format: expected an object',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
          'Failed to submit loan request: ${e.toString()}');
    }
  }
}
