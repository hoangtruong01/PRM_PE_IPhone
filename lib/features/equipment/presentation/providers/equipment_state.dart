// lib/features/equipment/presentation/providers/equipment_state.dart

import '../../domain/entities/device_entity.dart';

// ─── Các trạng thái của danh sách thiết bị ────────────────────────

/// Trạng thái cơ sở cho màn hình danh sách thiết bị
sealed class EquipmentListState {
  const EquipmentListState();
}

/// Trạng thái ban đầu trước khi bất kỳ dữ liệu nào được tải
class EquipmentListInitial extends EquipmentListState {
  const EquipmentListInitial();
}

/// Trạng thái đang tải trong khi lấy thông tin danh sách thiết bị
class EquipmentListLoading extends EquipmentListState {
  const EquipmentListLoading();
}

/// Trạng thái đã tải thành công với danh sách thiết bị kèm theo
class EquipmentListLoaded extends EquipmentListState {
  final List<DeviceEntity> devices;
  const EquipmentListLoaded(this.devices);
}

/// Trạng thái trống khi không có thiết bị nào
class EquipmentListEmpty extends EquipmentListState {
  const EquipmentListEmpty();
}

/// Trạng thái lỗi kèm theo thông điệp lỗi
class EquipmentListError extends EquipmentListState {
  final String message;
  const EquipmentListError(this.message);
}

// ─── Các trạng thái của chi tiết thiết bị ─────────────────────────

/// Trạng thái cơ sở cho màn hình chi tiết thiết bị
sealed class DeviceDetailState {
  const DeviceDetailState();
}

/// Trạng thái đang tải trong khi lấy chi tiết thiết bị
class DeviceDetailLoading extends DeviceDetailState {
  const DeviceDetailLoading();
}

/// Trạng thái đã tải thành công chi tiết thiết bị
class DeviceDetailLoaded extends DeviceDetailState {
  final DeviceEntity device;
  const DeviceDetailLoaded(this.device);
}

/// Trạng thái lỗi kèm theo thông điệp lỗi
class DeviceDetailError extends DeviceDetailState {
  final String message;
  const DeviceDetailError(this.message);
}
