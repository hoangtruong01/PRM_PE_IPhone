// lib/features/loan_request/data/datasources/loan_request_local_datasource.dart

import 'dart:convert';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/loan_request_model.dart';

/// Local DataSource for loan requests.
/// Handles saving/loading drafts and pending requests.
abstract class LoanRequestLocalDataSource {
  /// Save a draft loan request
  Future<void> saveDraft(LoanRequestModel request);

  /// Load a saved draft for a specific device
  LoanRequestModel? loadDraft(String deviceId);

  /// Delete a draft
  Future<void> deleteDraft(String deviceId);

  /// Save a pending request (for retry when offline)
  Future<void> savePendingRequest(LoanRequestModel request, String deviceName);

  /// Get all pending requests
  List<Map<String, dynamic>> getPendingRequests();

  /// Remove a pending request
  Future<void> removePendingRequest(int index);
}

class LoanRequestLocalDataSourceImpl implements LoanRequestLocalDataSource {
  final LocalStorage _localStorage;

  LoanRequestLocalDataSourceImpl(this._localStorage);

  @override
  Future<void> saveDraft(LoanRequestModel request) async {
    try {
      // Store drafts as a map keyed by deviceId
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
