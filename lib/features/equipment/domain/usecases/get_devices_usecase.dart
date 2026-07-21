// lib/features/equipment/domain/usecases/get_devices_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';
import '../repositories/equipment_repository.dart';

/// UseCase: Lấy danh sách tất cả các thiết bị.
/// Mỗi UseCase đóng gói một nghiệp vụ duy nhất (Single Responsibility).
/// Lớp UseCase này chỉ phụ thuộc vào giao diện Repository chứ không phụ thuộc vào lớp triển khai cụ thể.
class GetDevicesUseCase {
  final EquipmentRepository _repository;

  GetDevicesUseCase(this._repository);

  /// Thực thi UseCase
  Future<Result<List<DeviceEntity>>> call() {
    return _repository.getDevices();
  }
}
