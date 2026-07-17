// test/features/equipment/data/repositories/equipment_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/core/error/exceptions.dart';
import 'package:campus_equipment_loan/core/utils/result.dart';
import 'package:campus_equipment_loan/features/equipment/data/datasources/equipment_local_datasource.dart';
import 'package:campus_equipment_loan/features/equipment/data/datasources/equipment_remote_datasource.dart';
import 'package:campus_equipment_loan/features/equipment/data/models/device_model.dart';
import 'package:campus_equipment_loan/features/equipment/data/repositories/equipment_repository_impl.dart';
import 'package:campus_equipment_loan/features/equipment/domain/entities/device_entity.dart';

// ─── Fake DataSources ────────────────────────────────────────────

class FakeRemoteDataSource implements EquipmentRemoteDataSource {
  List<DeviceModel>? devicesResponse;
  DeviceModel? deviceByIdResponse;
  Exception? error;

  @override
  Future<List<DeviceModel>> getDevices() async {
    if (error != null) throw error!;
    return devicesResponse!;
  }

  @override
  Future<DeviceModel> getDeviceById(String id) async {
    if (error != null) throw error!;
    return deviceByIdResponse!;
  }
}

class FakeLocalDataSource implements EquipmentLocalDataSource {
  List<DeviceModel>? cachedDevices;
  List<DeviceModel>? savedDevices;
  bool _hasCached = false;

  @override
  Future<List<DeviceModel>> getCachedDevices() async {
    if (cachedDevices == null) {
      throw const CacheException('No cached devices');
    }
    return cachedDevices!;
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    savedDevices = devices;
    _hasCached = true;
  }

  @override
  bool hasCachedDevices() => _hasCached;
}

// ─── Tests ───────────────────────────────────────────────────────

void main() {
  late EquipmentRepositoryImpl repository;
  late FakeRemoteDataSource fakeRemote;
  late FakeLocalDataSource fakeLocal;

  final testModels = [
    DeviceModel.fromJson({
      'id': '1',
      'name': 'MacBook Pro 16',
      'data': {'year': 2019, 'price': 1849.99, 'CPU model': 'Intel Core i9'},
    }),
    DeviceModel.fromJson({
      'id': '2',
      'name': 'Samsung Galaxy S21',
      'data': {'year': 2021, 'price': 799},
    }),
  ];

  setUp(() {
    fakeRemote = FakeRemoteDataSource();
    fakeLocal = FakeLocalDataSource();
    repository = EquipmentRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );
  });

  group('getDevices', () {
    test('should return devices from remote and cache them', () async {
      // Arrange
      fakeRemote.devicesResponse = testModels;

      // Act
      final result = await repository.getDevices();

      // Assert
      expect(result, isA<Success<List<DeviceEntity>>>());
      final success = result as Success<List<DeviceEntity>>;
      expect(success.data.length, 2);
      expect(success.data[0].name, 'MacBook Pro 16');

      // Verify caching happened
      expect(fakeLocal.savedDevices, isNotNull);
      expect(fakeLocal.savedDevices!.length, 2);
    });

    test('should fallback to cache when remote fails', () async {
      // Arrange
      fakeRemote.error =
          const ServerException('Server error', statusCode: 500);
      fakeLocal.cachedDevices = testModels;

      // Act
      final result = await repository.getDevices();

      // Assert
      expect(result, isA<Success<List<DeviceEntity>>>());
      final success = result as Success<List<DeviceEntity>>;
      expect(success.data.length, 2);
    });

    test('should return error when both remote and cache fail', () async {
      // Arrange
      fakeRemote.error =
          const ServerException('Server error', statusCode: 500);
      fakeLocal.cachedDevices = null; // No cache

      // Act
      final result = await repository.getDevices();

      // Assert
      expect(result, isA<Error<List<DeviceEntity>>>());
    });
  });

  group('getDeviceById', () {
    test('should return device from remote', () async {
      // Arrange
      fakeRemote.deviceByIdResponse = testModels[0];

      // Act
      final result = await repository.getDeviceById('1');

      // Assert
      expect(result, isA<Success<DeviceEntity>>());
      final success = result as Success<DeviceEntity>;
      expect(success.data.id, '1');
      expect(success.data.name, 'MacBook Pro 16');
    });

    test('should fallback to cached list when remote fails', () async {
      // Arrange
      fakeRemote.error =
          const ServerException('Not found', statusCode: 404);
      fakeLocal.cachedDevices = testModels;

      // Act
      final result = await repository.getDeviceById('1');

      // Assert
      expect(result, isA<Success<DeviceEntity>>());
      final success = result as Success<DeviceEntity>;
      expect(success.data.name, 'MacBook Pro 16');
    });

    test('should return error when device not found in cache', () async {
      // Arrange
      fakeRemote.error =
          const ServerException('Not found', statusCode: 404);
      fakeLocal.cachedDevices = testModels;

      // Act
      final result = await repository.getDeviceById('999');

      // Assert
      expect(result, isA<Error<DeviceEntity>>());
    });
  });
}
