// lib/features/equipment/data/repositories/equipment_repository_impl.dart

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../datasources/equipment_local_datasource.dart';
import '../datasources/equipment_remote_datasource.dart';

/// Repository Implementation (Data Layer)
/// Implements the domain's EquipmentRepository interface.
/// Coordinates between remote and local data sources.
/// Converts exceptions from data sources into Failures for the domain layer.
///
/// Flow: Remote → Cache → Return entities
/// Fallback: If remote fails → try cache → if cache fails → return error
class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentRemoteDataSource _remoteDataSource;
  final EquipmentLocalDataSource _localDataSource;

  EquipmentRepositoryImpl({
    required EquipmentRemoteDataSource remoteDataSource,
    required EquipmentLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<DeviceEntity>>> getDevices() async {
    try {
      // Try remote first
      final models = await _remoteDataSource.getDevices();

      // Cache the result for offline use
      await _localDataSource.cacheDevices(models);

      // Convert models to entities
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
    } on ServerException catch (e) {
      // Remote failed — try cache as fallback
      try {
        final cachedModels = await _localDataSource.getCachedDevices();
        final entities = cachedModels.map((m) => m.toEntity()).toList();
        return Success(entities);
      } on CacheException {
        // Both remote and cache failed
        return Error(ServerFailure(e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      // Unexpected error — try cache
      try {
        final cachedModels = await _localDataSource.getCachedDevices();
        final entities = cachedModels.map((m) => m.toEntity()).toList();
        return Success(entities);
      } catch (_) {
        return Error(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Result<DeviceEntity>> getDeviceById(String id) async {
    try {
      final model = await _remoteDataSource.getDeviceById(id);
      return Success(model.toEntity());
    } on ServerException catch (e) {
      // Try to find in cached list
      try {
        final cachedModels = await _localDataSource.getCachedDevices();
        final model = cachedModels.firstWhere(
          (m) => m.id == id,
          orElse: () => throw const CacheException('Device not found in cache'),
        );
        return Success(model.toEntity());
      } on CacheException {
        return Error(ServerFailure(e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<DeviceEntity>>> getCachedDevices() async {
    try {
      final models = await _localDataSource.getCachedDevices();
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    }
  }
}
