// lib/features/loan_request/presentation/pages/loan_request_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/result.dart';
import '../../../equipment/presentation/providers/equipment_providers.dart';
import '../../../equipment/presentation/providers/equipment_state.dart';
import '../../../equipment/presentation/pages/equipment_catalogue_page.dart'; // To use CampusBottomNavBar
import '../../domain/entities/loan_request_entity.dart';
import '../providers/loan_request_providers.dart';
import '../providers/loan_request_state.dart';

/// Screen C — Loan Request Form
/// Student ID, Borrow Date, Return Date, Purpose, Request Summary.
class LoanRequestPage extends ConsumerStatefulWidget {
  final String deviceId;

  const LoanRequestPage({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<LoanRequestPage> createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends ConsumerState<LoanRequestPage> {
  // [GHI CHÚ] Khóa GlobalKey dùng để quản lý trạng thái của Form (validate, submit)
  final _formKey = GlobalKey<FormState>();

  // [GHI CHÚ] Bộ điều khiển nhập liệu (Controller) cho mã số sinh viên và lý do mượn
  final _studentIdController = TextEditingController();
  final _purposeController = TextEditingController();

  // [GHI CHÚ] Biến trạng thái lưu ngày mượn và ngày trả
  // Mặc định ngày mượn là hôm nay, ngày trả là 7 ngày sau
  DateTime _borrowDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    // [GHI CHÚ] Lắng nghe sự thay đổi của các ô nhập liệu để tự động lưu bản nháp (Draft)
    _studentIdController.addListener(_onFieldChanged);
    _purposeController.addListener(_onFieldChanged);
    
    // [GHI CHÚ] Tự động tải lại bản nháp đã lưu trong Local Storage sau khi giao diện render xong (post frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedDraft();
    });
  }

  @override
  void dispose() {
    // [GHI CHÚ] Hủy đăng ký lắng nghe sự kiện và hủy các controller để tránh rò rỉ bộ nhớ (memory leak)
    _studentIdController.removeListener(_onFieldChanged);
    _purposeController.removeListener(_onFieldChanged);
    _studentIdController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // [GHI CHÚ] Hàm kích hoạt lưu nháp mỗi khi người dùng thay đổi dữ liệu trong ô nhập
  void _onFieldChanged() {
    _saveDraft();
  }

  // [GHI CHÚ] Tính số ngày mượn (được tính bằng hiệu số ngày giữa ngày trả và ngày mượn)
  int get _loanPeriodDays => _returnDate.difference(_borrowDate).inDays;

  // [GHI CHÚ] Đọc bản nháp đã lưu từ cơ sở dữ liệu nội bộ (Local Storage) thông qua UseCase
  Future<void> _loadSavedDraft() async {
    try {
      final loadUseCase = await ref.read(loadDraftUseCaseProvider.future);
      final result = await loadUseCase(widget.deviceId);
      
      // Nếu tải bản nháp thành công và có dữ liệu, cập nhật lại trạng thái giao diện (UI state)
      if (result is Success<LoanRequestEntity?> && result.data != null) {
        final draft = result.data!;
        setState(() {
          _studentIdController.text = draft.studentId;
          _purposeController.text = draft.purpose;
          _borrowDate = draft.borrowDate;
          _returnDate = draft.returnDate;
        });
      }
    } catch (_) {}
  }

  // [GHI CHÚ] Lưu dữ liệu hiện tại vào bản nháp cục bộ (Local Storage) để không bị mất khi đóng app đột ngột
  Future<void> _saveDraft() async {
    try {
      final saveUseCase = await ref.read(saveDraftUseCaseProvider.future);
      final draft = LoanRequestEntity(
        deviceId: widget.deviceId,
        studentId: _studentIdController.text,
        borrowDate: _borrowDate,
        returnDate: _returnDate,
        purpose: _purposeController.text,
        deposit: 0.0, // Bản nháp chưa xử lý tiền cọc cụ thể
      );
      await saveUseCase(draft);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // [GHI CHÚ] Lắng nghe trạng thái chi tiết thiết bị và trạng thái gửi Form của Riverpod
    final deviceState = ref.watch(deviceDetailProvider(widget.deviceId));
    final formState = ref.watch(loanRequestFormStateProvider);

    const activeTeal = Color(0xFF0E9282);

    // [GHI CHÚ] Lắng nghe thay đổi trạng thái của formState để xử lý điều hướng hoặc hiển thị lỗi
    // Dùng ref.listen thay vì ref.watch vì hành động điều hướng/hiển thị SnackBar là side-effect (chỉ chạy 1 lần khi trạng thái thay đổi)
    ref.listen<LoanRequestFormState>(loanRequestFormStateProvider,
        (previous, next) {
      if (next is LoanRequestFormSuccess) {
        // [GHI CHÚ] Nếu gửi thành công, chuyển hướng tới trang Kết quả (RequestResultPage) kèm thông tin phản hồi
        final device = deviceState is DeviceDetailLoaded
            ? deviceState.device
            : null;
        context.push('/request-result', extra: {
          ...next.responseData,
          'deviceName': device?.name ?? 'Unknown Device',
          'borrowDate': _borrowDate.toIso8601String(),
          'returnDate': _returnDate.toIso8601String(),
          'deposit': device?.deposit ?? 0.0,
        });
      } else if (next is LoanRequestFormError) {
        // [GHI CHÚ] Nếu gặp lỗi, hiển thị thông báo SnackBar lỗi màu đỏ ở dưới màn hình
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Loan Request',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: switch (deviceState) {
        DeviceDetailLoading() => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(activeTeal),
            ),
          ),
        DeviceDetailError(:final message) => Center(
            child: Text(message),
          ),
        DeviceDetailLoaded(:final device) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student ID
                  const Text(
                    'Student ID',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      hintText: 'e.g. SE1819',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: activeTeal, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Student ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Borrow Date
                  const Text(
                    'Borrow date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildDateSelector(
                    context: context,
                    date: _borrowDate,
                    onDateSelected: (date) {
                      setState(() {
                        _borrowDate = date;
                        if (_returnDate.isBefore(_borrowDate) ||
                            _returnDate.isAtSameMomentAs(_borrowDate)) {
                          _returnDate =
                              _borrowDate.add(const Duration(days: 7));
                        }
                      });
                      _saveDraft();
                    },
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ),
                  const SizedBox(height: 18),

                  // Return Date
                  const Text(
                    'Return date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildDateSelector(
                    context: context,
                    date: _returnDate,
                    onDateSelected: (date) {
                      setState(() {
                        _returnDate = date;
                      });
                      _saveDraft();
                    },
                    firstDate: _borrowDate.add(const Duration(days: 1)),
                    lastDate: _borrowDate.add(const Duration(days: 14)),
                  ),
                  const SizedBox(height: 18),

                  // Purpose
                  const Text(
                    'Purpose',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _purposeController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Mobile app demo',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: activeTeal, width: 1.5),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Purpose is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Request Summary Card matching mockup C
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1), // Light green-teal bg
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request summary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: activeTeal,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildSummaryRow(
                          'Loan period',
                          '$_loanPeriodDays days',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow(
                          'Refundable deposit',
                          device.formattedDeposit,
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),

                  // Validation warning
                  if (_loanPeriodDays > 14 || _loanPeriodDays <= 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _loanPeriodDays <= 0
                                  ? 'Return date must be after borrow date'
                                  : 'Maximum loan period is 14 days',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (formState is LoanRequestFormSubmitting ||
                              _loanPeriodDays <= 0 ||
                              _loanPeriodDays > 14)
                          ? null
                          : () => _submitForm(device.name, device.deposit ?? 0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeTeal,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState is LoanRequestFormSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SUBMIT LOAN REQUEST',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
      },
      bottomNavigationBar: const CampusBottomNavBar(),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required DateTime date,
    required ValueChanged<DateTime> onDateSelected,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    const activeTeal = Color(0xFF0E9282);

    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: activeTeal,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selected != null) {
          onDateSelected(selected);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppDateUtils.formatDisplay(date),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false}) {
    const activeTeal = Color(0xFF0E9282);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? activeTeal : Colors.black87,
          ),
        ),
      ],
    );
  }

  // [GHI CHÚ] Hàm thực hiện gửi Form lên hệ thống
  void _submitForm(String deviceName, double deposit) {
    // 1. Kiểm tra tính hợp lệ của tất cả các trường nhập liệu trong Form (sử dụng validator của TextFormField)
    if (_formKey.currentState?.validate() ?? false) {
      // 2. Nếu Form hợp lệ, gọi hàm submitRequest của LoanRequestFormNotifier thông qua Riverpod
      // Dữ liệu bao gồm: ID thiết bị, Tên thiết bị, Mã số sinh viên, Ngày mượn, Ngày trả, Mục đích và Tiền đặt cọc.
      ref.read(loanRequestFormStateProvider.notifier).submitRequest(
            deviceId: widget.deviceId,
            deviceName: deviceName,
            studentId: _studentIdController.text.trim(),
            borrowDate: _borrowDate,
            returnDate: _returnDate,
            purpose: _purposeController.text.trim(),
            deposit: deposit,
          );
    }
  }
}
