// lib/features/equipment/domain/repositories/equipment_repository.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';

/// Repository Interface (Domain Layer)
/// Defines the contract for data operations. The domain layer depends on
/// this abstraction, NOT on the concrete implementation (Dependency Inversion).
/// This makes the domain layer independent of data sources (API, cache, etc.)
abstract class EquipmentRepository {
  /// Get all devices from remote API (with cache fallback)
  Future<Result<List<DeviceEntity>>> getDevices();

  /// Get a single device by ID
  Future<Result<DeviceEntity>> getDeviceById(String id);

  /// Get devices from local cache
  Future<Result<List<DeviceEntity>>> getCachedDevices();
}
