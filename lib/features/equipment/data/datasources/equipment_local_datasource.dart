// lib/features/equipment/data/datasources/equipment_local_datasource.dart

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/device_model.dart';

/// Nguồn dữ liệu cục bộ (Local DataSource): Xử lý việc lưu cache dữ liệu thiết bị vào SharedPreferences.
/// Cung cấp hỗ trợ ngoại tuyến — khi remote API không khả dụng,
/// Repository có thể chuyển sang sử dụng dữ liệu đã lưu trong cache này.
abstract class EquipmentLocalDataSource {
  /// Lấy các thiết bị từ cache cục bộ
  Future<List<DeviceModel>> getCachedDevices();

  /// Lưu danh sách các thiết bị vào cache cục bộ
  Future<void> cacheDevices(List<DeviceModel> devices);

  /// Kiểm tra xem dữ liệu cache có tồn tại không
  bool hasCachedDevices();
}

class EquipmentLocalDataSourceImpl implements EquipmentLocalDataSource {
  final LocalStorage _localStorage;

  EquipmentLocalDataSourceImpl(this._localStorage);

  @override
  Future<List<DeviceModel>> getCachedDevices() async {
    final jsonString = _localStorage.getString(StorageConstants.cachedDevices);

    if (jsonString == null || jsonString.isEmpty) {
      throw const CacheException('No cached devices found');
    }

    try {
      return DeviceModel.listFromJsonString(jsonString);
    } catch (e) {
      throw CacheException('Failed to parse cached devices: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    final jsonString = DeviceModel.listToJsonString(devices);
    await _localStorage.saveString(StorageConstants.cachedDevices, jsonString);
  }

  @override
  bool hasCachedDevices() {
    return _localStorage.containsKey(StorageConstants.cachedDevices);
  }
}
