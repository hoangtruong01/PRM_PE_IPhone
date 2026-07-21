// lib/features/loan_request/data/datasources/loan_request_remote_datasource.dart

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/loan_request_model.dart';

/// Nguồn dữ liệu từ xa (Remote DataSource) cho các yêu cầu mượn thiết bị.
/// Xử lý yêu cầu POST để gửi yêu cầu mượn.
abstract class LoanRequestRemoteDataSource {
  /// Gửi yêu cầu mượn thiết bị lên API
  /// Trả về phản hồi JSON thô chứa id, createdAt, v.v.
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
