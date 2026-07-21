// lib/features/equipment/data/datasources/equipment_remote_datasource.dart

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/device_model.dart';

/// Nguồn dữ liệu từ xa (Remote DataSource): Xử lý toàn bộ giao tiếp HTTP với API.
/// Chỉ có lớp này biết về hạ tầng mạng; Repository không cần quan tâm
/// dữ liệu được lấy từ HTTP, WebSocket, hay GraphQL.
abstract class EquipmentRemoteDataSource {
  /// Lấy tất cả thiết bị từ remote API
  Future<List<DeviceModel>> getDevices();

  /// Lấy thông tin một thiết bị theo ID từ remote API
  Future<DeviceModel> getDeviceById(String id);
}

class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final NetworkClient _networkClient;

  EquipmentRemoteDataSourceImpl(this._networkClient);

  @override
  Future<List<DeviceModel>> getDevices() async {
    try {
      final response = await _networkClient.get(ApiConstants.devicesUrl);

      if (response is List) {
        return DeviceModel.fromJsonList(response);
      } else {
        throw const ServerException('Invalid response format: expected a list');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch devices: ${e.toString()}');
    }
  }

  @override
  Future<DeviceModel> getDeviceById(String id) async {
    try {
      final response =
          await _networkClient.get(ApiConstants.deviceByIdUrl(id));

      if (response is Map<String, dynamic>) {
        return DeviceModel.fromJson(response);
      } else {
        throw const ServerException(
            'Invalid response format: expected an object');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch device $id: ${e.toString()}');
    }
  }
}
