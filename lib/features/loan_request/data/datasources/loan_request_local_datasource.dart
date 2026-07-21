// lib/features/loan_request/data/datasources/loan_request_local_datasource.dart

import 'dart:convert';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/loan_request_model.dart';

/// Nguồn dữ liệu cục bộ (Local DataSource) cho các yêu cầu mượn thiết bị.
/// Xử lý việc lưu/tải các bản nháp và các yêu cầu đang chờ đồng bộ.
abstract class LoanRequestLocalDataSource {
  /// Lưu bản nháp của yêu cầu mượn
  Future<void> saveDraft(LoanRequestModel request);

  /// Tải bản nháp đã lưu cho một thiết bị cụ thể
  LoanRequestModel? loadDraft(String deviceId);

  /// Xóa bản nháp
  Future<void> deleteDraft(String deviceId);

  /// Lưu yêu cầu đang chờ xử lý (để thử lại khi ngoại tuyến)
  Future<void> savePendingRequest(LoanRequestModel request, String deviceName);

  /// Lấy tất cả các yêu cầu đang chờ xử lý
  List<Map<String, dynamic>> getPendingRequests();

  /// Xóa một yêu cầu đang chờ xử lý khỏi hàng đợi
  Future<void> removePendingRequest(int index);
}

class LoanRequestLocalDataSourceImpl implements LoanRequestLocalDataSource {
  final LocalStorage _localStorage;

  LoanRequestLocalDataSourceImpl(this._localStorage);

  @override
  Future<void> saveDraft(LoanRequestModel request) async {
    try {
      // Lưu các bản nháp dưới dạng map với khóa là deviceId
      final draftsJson =
          _localStorage.getString(StorageConstants.loanDraft) ?? '{}';
      final Map<String, dynamic> drafts = json.decode(draftsJson);
      drafts[request.deviceId] = request.toJson();
      await _localStorage.saveString(
          StorageConstants.loanDraft, json.encode(drafts));
    } catch (e) {
      throw CacheException('Failed to save draft: ${e.toString()}');
    }
  }

  @override
  LoanRequestModel? loadDraft(String deviceId) {
    try {
      final draftsJson =
          _localStorage.getString(StorageConstants.loanDraft) ?? '{}';
      final Map<String, dynamic> drafts = json.decode(draftsJson);
      if (drafts.containsKey(deviceId)) {
        return LoanRequestModel.fromJson(
            drafts[deviceId] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteDraft(String deviceId) async {
    try {
      final draftsJson =
          _localStorage.getString(StorageConstants.loanDraft) ?? '{}';
      final Map<String, dynamic> drafts = json.decode(draftsJson);
      drafts.remove(deviceId);
      await _localStorage.saveString(
          StorageConstants.loanDraft, json.encode(drafts));
    } catch (e) {
      throw CacheException('Failed to delete draft: ${e.toString()}');
    }
  }

  @override
  Future<void> savePendingRequest(
      LoanRequestModel request, String deviceName) async {
    try {
      final pendingJson =
          _localStorage.getString(StorageConstants.pendingRequests) ?? '[]';
      final List<dynamic> pending = json.decode(pendingJson);
      pending.add({
        'request': request.toJson(),
        'deviceName': deviceName,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _localStorage.saveString(
          StorageConstants.pendingRequests, json.encode(pending));
    } catch (e) {
      throw CacheException('Failed to save pending request: ${e.toString()}');
    }
  }

  @override
  List<Map<String, dynamic>> getPendingRequests() {
    try {
      final pendingJson =
          _localStorage.getString(StorageConstants.pendingRequests) ?? '[]';
      final List<dynamic> pending = json.decode(pendingJson);
      return pending.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> removePendingRequest(int index) async {
    try {
      final pendingJson =
          _localStorage.getString(StorageConstants.pendingRequests) ?? '[]';
      final List<dynamic> pending = json.decode(pendingJson);
      if (index >= 0 && index < pending.length) {
        pending.removeAt(index);
        await _localStorage.saveString(
            StorageConstants.pendingRequests, json.encode(pending));
      }
    } catch (e) {
      throw CacheException(
          'Failed to remove pending request: ${e.toString()}');
    }
  }
}
