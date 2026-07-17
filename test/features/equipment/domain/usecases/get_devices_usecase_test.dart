// test/features/equipment/domain/usecases/get_devices_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/core/error/failures.dart';
import 'package:campus_equipment_loan/core/utils/result.dart';
import 'package:campus_equipment_loan/features/equipment/domain/entities/device_entity.dart';
import 'package:campus_equipment_loan/features/equipment/domain/repositories/equipment_repository.dart';
import 'package:campus_equipment_loan/features/equipment/domain/usecases/get_devices_usecase.dart';

/// Fake repository for testing (no mockito dependency needed)
class FakeEquipmentRepository implements EquipmentRepository {
  Result<List<DeviceEntity>>? devicesResult;
  Result<DeviceEntity>? deviceByIdResult;

  @override
  Future<Result<List<DeviceEntity>>> getDevices() async {
    return devicesResult!;
  }

  @override
  Future<Result<DeviceEntity>> getDeviceById(String id) async {
    return deviceByIdResult!;
  }

  @override
  Future<Result<List<DeviceEntity>>> getCachedDevices() async {
    return devicesResult!;
  }
}

void main() {
  late GetDevicesUseCase useCase;
  late FakeEquipmentRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeEquipmentRepository();
    useCase = GetDevicesUseCase(fakeRepository);
  });

  group('GetDevicesUseCase', () {
    final testDevices = [
      const DeviceEntity(
        id: '1',
        name: 'MacBook Pro 16',
        category: 'Laptop',
        price: 1849,
        year: 2019,
        deposit: 50,
      ),
      const DeviceEntity(
        id: '2',
        name: 'Samsung Galaxy',
        category: 'Phone',
        price: 799,
        year: 2022,
        deposit: 20,
      ),
    ];

    test('should return list of devices on success', () async {
      // Arrange
      fakeRepository.devicesResult = Success(testDevices);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Success<List<DeviceEntity>>>());
      final success = result as Success<List<DeviceEntity>>;
      expect(success.data.length, 2);
      expect(success.data[0].name, 'MacBook Pro 16');
      expect(success.data[1].name, 'Samsung Galaxy');
    });

    test('should return empty list when no devices available', () async {
      // Arrange
      fakeRepository.devicesResult = const Success([]);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Success<List<DeviceEntity>>>());
      final success = result as Success<List<DeviceEntity>>;
      expect(success.data, isEmpty);
    });

    test('should return error when repository fails', () async {
      // Arrange
      fakeRepository.devicesResult =
          const Error(ServerFailure('Server error', statusCode: 500));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<List<DeviceEntity>>>());
      final error = result as Error<List<DeviceEntity>>;
      expect(error.failure.message, 'Server error');
      expect((error.failure as ServerFailure).statusCode, 500);
    });

    test('should return network failure when offline', () async {
      // Arrange
      fakeRepository.devicesResult =
          const Error(NetworkFailure('No internet connection'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Error<List<DeviceEntity>>>());
      final error = result as Error<List<DeviceEntity>>;
      expect(error.failure, isA<NetworkFailure>());
    });
  });
}
