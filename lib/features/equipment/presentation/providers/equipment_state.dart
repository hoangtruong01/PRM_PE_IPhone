// lib/features/equipment/presentation/providers/equipment_state.dart

import '../../domain/entities/device_entity.dart';

// ─── Equipment List States ───────────────────────────────────────

/// Base state for the equipment list screen
sealed class EquipmentListState {
  const EquipmentListState();
}

/// Initial state before any data is loaded
class EquipmentListInitial extends EquipmentListState {
  const EquipmentListInitial();
}

/// Loading state while fetching devices
class EquipmentListLoading extends EquipmentListState {
  const EquipmentListLoading();
}

/// Loaded state with list of devices
class EquipmentListLoaded extends EquipmentListState {
  final List<DeviceEntity> devices;
  const EquipmentListLoaded(this.devices);
}

/// Empty state when no devices are available
class EquipmentListEmpty extends EquipmentListState {
  const EquipmentListEmpty();
}

/// Error state with error message
class EquipmentListError extends EquipmentListState {
  final String message;
  const EquipmentListError(this.message);
}

// ─── Device Detail States ────────────────────────────────────────

/// Base state for the device detail screen
sealed class DeviceDetailState {
  const DeviceDetailState();
}

/// Loading state while fetching device details
class DeviceDetailLoading extends DeviceDetailState {
  const DeviceDetailLoading();
}

/// Loaded state with device details
class DeviceDetailLoaded extends DeviceDetailState {
  final DeviceEntity device;
  const DeviceDetailLoaded(this.device);
}

/// Error state with error message
class DeviceDetailError extends DeviceDetailState {
  final String message;
  const DeviceDetailError(this.message);
}
