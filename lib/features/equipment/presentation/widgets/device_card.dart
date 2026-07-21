// lib/features/equipment/presentation/widgets/device_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/device_entity.dart';

/// Widget thẻ hiển thị tóm tắt thông tin thiết bị trong danh sách danh mục.
/// Khớp với giao diện thiết kế: hộp danh mục ở bên trái, tên, năm, giá trị và tiền cọc ở bên phải.
class DeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isInWatchlist;
  final bool isInCompareList;
  final VoidCallback onTap;
  final VoidCallback onWatchlistTap;
  final VoidCallback onCompareTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isInWatchlist,
    required this.isInCompareList,
    required this.onTap,
    required this.onWatchlistTap,
    required this.onCompareTap,
  });

  Color _categoryBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return const Color(0xFFE0F2F1); // Light teal/green
      case 'phone':
        return const Color(0xFFE3F2FD); // Light blue
      default:
        return const Color(0xFFF3E5F5); // Light purple
    }
  }

  Color _categoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return const Color(0xFF0E9282); // Active teal
      case 'phone':
        return const Color(0xFF1E88E5); // Active blue
      default:
        return const Color(0xFF8E24AA); // Active purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _categoryBgColor(device.category);
    final textColor = _categoryTextColor(device.category);
    final primaryTeal = const Color(0xFF0E9282);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Huy hiệu Danh mục lớn ở bên trái (Large Category badge on the left)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  device.category.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Thông tin thiết bị ở giữa (Device info in the center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.category} • ${device.year != null ? device.year.toString() : "Unknown year"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${device.formattedPrice} • Deposit ${device.formattedDeposit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),

              // Các nút hành động (Bookmark và So sánh) (Action buttons)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      isInWatchlist
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isInWatchlist ? primaryTeal : Colors.grey.shade400,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onWatchlistTap,
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(
                      isInCompareList
                          ? Icons.compare_arrows_rounded
                          : Icons.compare_arrows_rounded,
                      color: isInCompareList ? primaryTeal : Colors.grey.shade400,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onCompareTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
