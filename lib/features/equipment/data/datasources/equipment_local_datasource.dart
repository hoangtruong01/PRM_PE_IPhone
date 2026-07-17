// lib/features/equipment/data/datasources/equipment_local_datasource.dart

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/device_model.dart';

/// Local DataSource: Handles caching of device data in SharedPreferences.
/// Provides offline support — when the remote API is unavailable,
/// the Repository can fall back to cached data.
abstract class EquipmentLocalDataSource {
  /// Get cached devices
  Future<List<DeviceModel>> getCachedDevices();

  /// Cache a list of devices
  Future<void> cacheDevices(List<DeviceModel> devices);

  /// Check if cached data exists
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
