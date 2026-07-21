// lib/features/loan_request/presentation/pages/request_result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../equipment/presentation/pages/equipment_catalogue_page.dart'; // To use CampusBottomNavBar

/// Màn hình D — Kết quả yêu cầu mượn thiết bị
/// Hiển thị xác nhận yêu cầu mượn với dữ liệu trả về từ phản hồi của POST.
/// Hiển thị: Mã yêu cầu, Thiết bị, Thời hạn mượn, Tiền cọc, Trạng thái.
class RequestResultPage extends ConsumerWidget {
  final Map<String, dynamic> resultData;

  const RequestResultPage({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const activeTeal = Color(0xFF0E9282);

    final isOffline = resultData['isOffline'] == true;
    final requestId = resultData['id']?.toString() ?? 'ff808181';
    final deviceName = resultData['deviceName']?.toString() ?? 'Unknown Device';
    final borrowDateStr = resultData['borrowDate']?.toString();
    final returnDateStr = resultData['returnDate']?.toString();
    final deposit = resultData['deposit'];

    // Phân tích ngày tháng (Parse dates)
    DateTime? borrowDate;
    DateTime? returnDate;
    try {
      if (borrowDateStr != null) borrowDate = DateTime.parse(borrowDateStr);
      if (returnDateStr != null) returnDate = DateTime.parse(returnDateStr);
    } catch (_) {}

    // Định dạng thời gian mượn sang dạng dd-dd MMM (ví dụ: 01-07 Aug)
    String loanPeriod = 'N/A';
    if (borrowDate != null && returnDate != null) {
      final startDay = borrowDate.day.toString().padLeft(2, '0');
      final endDay = returnDate.day.toString().padLeft(2, '0');
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[borrowDate.month - 1];
      loanPeriod = '$startDay-$endDay $monthStr';
    }

    // Định dạng tiền đặt cọc
    String depositStr = 'N/A';
    if (deposit != null) {
      if (deposit is num) {
        depositStr = '\$${deposit.toStringAsFixed(0)}';
      } else {
        depositStr = '\$$deposit';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Request Result',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Vòng tròn dấu tích (Checkmark) khớp với bản vẽ mẫu D
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1), // Màu nền teal nhạt
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: activeTeal,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề "Yêu cầu mượn thiết bị đã được tạo"
            const Text(
              'Loan request created',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Phụ đề "Mã yêu cầu #ff808181" hoặc thông báo Offline
            Text(
              isOffline ? 'Saved locally (Pending Sync)' : 'Request ID #$requestId',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),

            // Hộp chi tiết (Details Box) khớp với bản vẽ mẫu D
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildResultRow('Device', deviceName),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow('Loan period', loanPeriod),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow('Deposit', depositStr, valueColor: activeTeal),
                  const Divider(height: 24, color: Color(0xFFF5F5F5)),
                  _buildResultRow(
                    'Status', 
                    isOffline ? 'Pending Sync' : 'Pending approval', 
                    valueColor: activeTeal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Nút "QUAY LẠI THIẾT BỊ" (BACK TO DEVICES)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BACK TO DEVICES',
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
      bottomNavigationBar: const CampusBottomNavBar(),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
