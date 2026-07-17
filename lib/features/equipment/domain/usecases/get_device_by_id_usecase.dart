// lib/features/equipment/domain/usecases/get_device_by_id_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';
import '../repositories/equipment_repository.dart';

/// UseCase: Get a single device by its ID.
/// Follows the Single Responsibility Principle — one action per class.
class GetDeviceByIdUseCase {
  final EquipmentRepository _repository;

  GetDeviceByIdUseCase(this._repository);

  /// Execute the use case with a device ID
  Future<Result<DeviceEntity>> call(String id) {
    return _repository.getDeviceById(id);
  }
}
