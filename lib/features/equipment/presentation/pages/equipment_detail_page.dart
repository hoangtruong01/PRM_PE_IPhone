// lib/features/equipment/presentation/pages/equipment_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/device_entity.dart';
import '../providers/equipment_providers.dart';
import '../providers/equipment_state.dart';
import 'equipment_catalogue_page.dart'; // To use CampusBottomNavBar

/// Màn hình B — Chi tiết thiết bị
/// Hiển thị thông tin thiết bị và các phương án xử lý nếu dữ liệu bị khuyết thiếu.
/// Cung cấp nút "REQUEST THIS DEVICE" để chuyển sang biểu mẫu đăng ký mượn thiết bị.
class EquipmentDetailPage extends ConsumerWidget {
  final String deviceId;

  const EquipmentDetailPage({
    super.key,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceDetailProvider(deviceId));
    final watchlist = ref.watch(watchlistProvider);
    final isInWatchlist = watchlist.contains(deviceId);

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
          'Device Detail',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isInWatchlist
                  ? const Color(0xFF0E9282)
                  : Colors.grey.shade400,
            ),
            onPressed: () {
              ref.read(watchlistProvider.notifier).toggle(deviceId);
            },
          ),
        ],
      ),
      body: switch (state) {
        DeviceDetailLoading() => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E9282)),
            ),
          ),
        DeviceDetailError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(deviceDetailProvider(deviceId).notifier).refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        DeviceDetailLoaded(:final device) =>
          _buildDeviceDetail(context, ref, device),
      },
      bottomNavigationBar: const CampusBottomNavBar(),
    );
  }

  Widget _buildDeviceDetail(
    BuildContext context,
    WidgetRef ref,
    DeviceEntity device,
  ) {
    const activeTeal = Color(0xFF0E9282);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khung hiển thị ảnh thiết bị (placeholder) khớp với bản vẽ mẫu B
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1), // Nền xanh-teal nhạt
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'DEVICE IMAGE',
                  style: TextStyle(
                    color: Color(0xFF0E9282), // Chữ màu teal
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Tên thiết bị (Device Name)
            Text(
              device.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Phụ đề (Subtitle)
            Text(
              '${device.category} • Year ${device.year ?? "Unknown"}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),

            // Giá trị ước tính (Estimated Value)
            Text(
              'Estimated value: ${device.formattedPrice}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E9282),
              ),
            ),
            const SizedBox(height: 20),

            // Bảng hộp thông số kỹ thuật (CPU và tiền đặt cọc)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nhãn & Giá trị CPU (CPU Label & Value)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CPU',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          device.cpuModel ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nhãn & Giá trị Tiền đặt cọc (Deposit Label & Value)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        device.formattedDeposit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E9282),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Phần Chính sách mượn thiết bị (Loan Policy Section)
            const Text(
              'Loan policy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maximum loan period is 14 days. The request remains pending until staff approval.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // Nút gửi yêu cầu mượn thiết bị này (REQUEST THIS DEVICE Button)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/loan-request/${device.id}');
                },
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
                  'REQUEST THIS DEVICE',
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
    );
  }
}
