// lib/features/equipment/data/datasources/equipment_remote_datasource.dart

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/device_model.dart';

/// Remote DataSource: Handles all HTTP communication with the API.
/// Only this class knows about the network; Repository doesn't care
/// whether data comes from HTTP, WebSocket, or GraphQL.
abstract class EquipmentRemoteDataSource {
  /// Fetch all devices from the remote API
  Future<List<DeviceModel>> getDevices();

  /// Fetch a single device by ID from the remote API
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
