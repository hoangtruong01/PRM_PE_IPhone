// lib/features/equipment/domain/usecases/get_devices_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';
import '../repositories/equipment_repository.dart';

/// UseCase: Get all devices.
/// Each UseCase encapsulates a single business action (Single Responsibility).
/// The UseCase depends on the Repository interface, not the implementation.
class GetDevicesUseCase {
  final EquipmentRepository _repository;

  GetDevicesUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<DeviceEntity>>> call() {
    return _repository.getDevices();
  }
}
