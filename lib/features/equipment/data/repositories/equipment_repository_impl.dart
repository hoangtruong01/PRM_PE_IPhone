// lib/features/equipment/data/repositories/equipment_repository_impl.dart

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../datasources/equipment_local_datasource.dart';
import '../datasources/equipment_remote_datasource.dart';

/// Triển khai Repository (Data Layer)
/// Triển khai giao diện EquipmentRepository của lớp domain.
/// Điều phối hoạt động giữa các nguồn dữ liệu từ xa và cục bộ.
/// Chuyển đổi ngoại lệ từ các nguồn dữ liệu thành các Lỗi (Failures) cho lớp domain.
///
/// Luồng hoạt động: Remote → Cache → Trả về các thực thể (entities)
/// Dự phòng: Nếu lấy từ remote lỗi → thử lấy từ cache → nếu cache lỗi → trả về lỗi
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
      // Thử lấy dữ liệu từ remote trước
      final models = await _remoteDataSource.getDevices();

      // Lưu kết quả vào cache để sử dụng khi ngoại tuyến
      await _localDataSource.cacheDevices(models);

      // Chuyển đổi các models thành thực thể (entities)
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
    } on ServerException catch (e) {
      // Lấy từ remote thất bại — thử lấy từ cache làm phương án dự phòng
      try {
        final cachedModels = await _localDataSource.getCachedDevices();
        final entities = cachedModels.map((m) => m.toEntity()).toList();
        return Success(entities);
      } on CacheException {
        // Cả remote và cache đều thất bại
        return Error(ServerFailure(e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      // Lỗi không mong muốn — thử lấy từ cache
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
      // Thử tìm thiết bị trong danh sách đã lưu cache
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
