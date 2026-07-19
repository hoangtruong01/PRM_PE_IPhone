// lib/features/loan_request/presentation/providers/loan_request_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../../core/utils/result.dart';
import '../../../equipment/presentation/providers/equipment_providers.dart';
import '../../../loan_request/data/models/loan_request_model.dart';
import '../../../loan_request/domain/usecases/save_draft_usecase.dart';
import '../../../loan_request/domain/usecases/load_draft_usecase.dart';
import '../../../loan_request/domain/usecases/delete_draft_usecase.dart';
import '../../data/datasources/loan_request_local_datasource.dart';
import '../../data/datasources/loan_request_remote_datasource.dart';
import '../../data/repositories/loan_request_repository_impl.dart';
import '../../domain/entities/loan_request_entity.dart';
import '../../domain/repositories/loan_request_repository.dart';
import '../../domain/usecases/submit_loan_request_usecase.dart';
import '../../../../app/providers.dart';
import 'loan_request_state.dart';

// ─── DataSource Providers ────────────────────────────────────────

final loanRequestRemoteDataSourceProvider =
    Provider<LoanRequestRemoteDataSource>((ref) {
  return LoanRequestRemoteDataSourceImpl(ref.watch(networkClientProvider));
});

final loanRequestLocalDataSourceProvider =
    FutureProvider<LoanRequestLocalDataSource>((ref) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return LoanRequestLocalDataSourceImpl(localStorage);
});

// ─── Repository Provider ─────────────────────────────────────────

final loanRequestRepositoryProvider =
    FutureProvider<LoanRequestRepository>((ref) async {
  final remoteDataSource = ref.watch(loanRequestRemoteDataSourceProvider);
  final localDataSource =
      await ref.watch(loanRequestLocalDataSourceProvider.future);
  return LoanRequestRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// ─── UseCase Providers ───────────────────────────────────────────

final submitLoanRequestUseCaseProvider =
    FutureProvider<SubmitLoanRequestUseCase>((ref) async {
  final repository = await ref.watch(loanRequestRepositoryProvider.future);
  return SubmitLoanRequestUseCase(repository);
});

final saveDraftUseCaseProvider =
    FutureProvider<SaveDraftUseCase>((ref) async {
  final repository = await ref.watch(loanRequestRepositoryProvider.future);
  return SaveDraftUseCase(repository);
});

final loadDraftUseCaseProvider =
    FutureProvider<LoadDraftUseCase>((ref) async {
  final repository = await ref.watch(loanRequestRepositoryProvider.future);
  return LoadDraftUseCase(repository);
});

final deleteDraftUseCaseProvider =
    FutureProvider<DeleteDraftUseCase>((ref) async {
  final repository = await ref.watch(loanRequestRepositoryProvider.future);
  return DeleteDraftUseCase(repository);
});

// ─── State Providers ──────────────────────────────────────────────

final loanRequestFormStateProvider = StateNotifierProvider.autoDispose<
    LoanRequestFormNotifier, LoanRequestFormState>((ref) {
  return LoanRequestFormNotifier(ref);
});

// ─── State Notifier ──────────────────────────────────────────────

class LoanRequestFormNotifier extends StateNotifier<LoanRequestFormState> {
  final Ref _ref;

  LoanRequestFormNotifier(this._ref) : super(const LoanRequestFormInitial());

  // [GHI CHÚ] Hàm xử lý gửi yêu cầu mượn thiết bị
  Future<void> submitRequest({
    required String deviceId,
    required String deviceName,
    required String studentId,
    required DateTime borrowDate,
    required DateTime returnDate,
    required String purpose,
    required double deposit,
  }) async {
    // 1. Chuyển trạng thái Form sang đang gửi (Submitting) để hiển thị indicator load trên giao diện
    state = const LoanRequestFormSubmitting();

    // 2. Tạo đối tượng Entity lưu trữ thông tin yêu cầu mượn
    final request = LoanRequestEntity(
      deviceId: deviceId,
      studentId: studentId,
      borrowDate: borrowDate,
      returnDate: returnDate,
      purpose: purpose,
      deposit: deposit,
      status: 'pending',
    );

    // 3. Kiểm tra trạng thái mạng của ứng dụng thông qua isOfflineProvider
    final isOffline = _ref.read(isOfflineProvider);
    if (isOffline) {
      try {
        // [TRƯỜNG HỢP OFFLINE]
        // 3.1 Lấy nguồn dữ liệu Local và lưu yêu cầu mượn tạm thời vào cơ sở dữ liệu nội bộ (Pending Request)
        final localDS = await _ref.read(loanRequestLocalDataSourceProvider.future);
        final model = LoanRequestModel.fromEntity(request);
        await localDS.savePendingRequest(model, deviceName);
        
        // 3.2 Xóa bản nháp (Draft) của thiết bị này vì đã gửi yêu cầu mượn thành công (đang chờ đồng bộ)
        final deleteUseCase = await _ref.read(deleteDraftUseCaseProvider.future);
        await deleteUseCase(deviceId);

        // 3.3 Trả về trạng thái Thành công tạm thời với cờ hiệu 'isOffline': true
        state = LoanRequestFormSuccess({
          'id': 'offline_${DateTime.now().millisecondsSinceEpoch}',
          'createdAt': 'Saved locally (Pending Sync)',
          'deviceName': deviceName,
          'borrowDate': borrowDate.toIso8601String(),
          'returnDate': returnDate.toIso8601String(),
          'deposit': deposit,
          'status': 'pending',
          'isOffline': true,
        });
      } catch (e) {
        // Nếu lưu nội bộ thất bại, trả về trạng thái Lỗi
        state = LoanRequestFormError('Offline submission failed: ${e.toString()}');
      }
      return;
    }

    // [TRƯỜNG HỢP ONLINE]
    try {
      // 3.4 Gọi UseCase SubmitLoanRequest để gửi yêu cầu lên server thông qua Remote DataSource
      final useCase =
          await _ref.read(submitLoanRequestUseCaseProvider.future);
      final result = await useCase(
        request: request,
        deviceName: deviceName,
      );

      // 3.5 Nhận kết quả từ UseCase và cập nhật State tương ứng (Success hoặc Error)
      switch (result) {
        case Success<Map<String, dynamic>>():
          state = LoanRequestFormSuccess(result.data);
        case Error<Map<String, dynamic>>():
          state = LoanRequestFormError(result.failure.message);
      }
    } catch (e) {
      state = LoanRequestFormError('Failed to submit: ${e.toString()}');
    }
  }

  // [GHI CHÚ] Reset lại trạng thái Form về mặc định ban đầu
  void reset() {
    state = const LoanRequestFormInitial();
  }
}

// ─── Pending Request Sync Provider ────────────────────────────────

final pendingRequestSyncProvider = StateNotifierProvider<PendingRequestSyncNotifier, bool>((ref) {
  return PendingRequestSyncNotifier(ref);
});

class PendingRequestSyncNotifier extends StateNotifier<bool> {
  final Ref _ref;

  PendingRequestSyncNotifier(this._ref) : super(false) {
    // Listen to network status changes. When we go from offline to online, sync!
    _ref.listen<bool>(isOfflineProvider, (previous, current) {
      if (previous == true && current == false) {
        syncPendingRequests();
      }
    });
  }

  Future<void> syncPendingRequests() async {
    if (state) return; // Already syncing
    state = true;
    try {
      final localDataSource = await _ref.read(loanRequestLocalDataSourceProvider.future);
      final remoteDataSource = _ref.read(loanRequestRemoteDataSourceProvider);

      final pending = localDataSource.getPendingRequests();
      if (pending.isEmpty) {
        state = false;
        return;
      }

      // Sync backwards to safely delete completed items by index
      for (int i = pending.length - 1; i >= 0; i--) {
        final item = pending[i];
        final requestMap = item['request'] as Map<String, dynamic>;
        final deviceName = item['deviceName'] as String;

        final model = LoanRequestModel.fromJson(requestMap);

        try {
          await remoteDataSource.submitLoanRequest(model, deviceName: deviceName);
          await localDataSource.removePendingRequest(i);
        } catch (_) {
          // If individual POST fails, it stays in the queue to be retried
        }
      }
    } catch (_) {}
    state = false;
  }
}
