// lib/features/equipment/domain/usecases/get_device_by_id_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/device_entity.dart';
import '../repositories/equipment_repository.dart';

/// UseCase: Lấy thông tin một thiết bị cụ thể theo ID.
/// Tuân thủ Nguyên tắc Đơn nhiệm (Single Responsibility Principle) — mỗi lớp chỉ thực hiện một nghiệp vụ duy nhất.
class GetDeviceByIdUseCase {
  final EquipmentRepository _repository;

  GetDeviceByIdUseCase(this._repository);

  /// Thực thi UseCase với ID của thiết bị
  Future<Result<DeviceEntity>> call(String id) {
    return _repository.getDeviceById(id);
  }
}
