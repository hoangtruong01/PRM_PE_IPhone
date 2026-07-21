// lib/features/equipment/domain/repositories/equipment_repository.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';

/// Giao diện Repository (Domain Layer)
/// Định nghĩa các hàm thao tác với dữ liệu. Lớp domain phụ thuộc vào
/// lớp trừu tượng này chứ KHÔNG phụ thuộc vào triển khai chi tiết (Dependency Inversion).
/// Nhờ đó, lớp domain hoàn toàn độc lập với nguồn dữ liệu (API, cache, v.v.)
abstract class EquipmentRepository {
  /// Lấy tất cả thiết bị từ remote API (có hỗ trợ lấy từ cache dự phòng)
  Future<Result<List<DeviceEntity>>> getDevices();

  /// Lấy thông tin chi tiết một thiết bị theo ID
  Future<Result<DeviceEntity>> getDeviceById(String id);

  /// Lấy danh sách thiết bị từ cache cục bộ
  Future<Result<List<DeviceEntity>>> getCachedDevices();
}
