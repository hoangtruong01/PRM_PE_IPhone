// lib/features/equipment/presentation/providers/equipment_providers.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/equipment_local_datasource.dart';
import '../../data/datasources/equipment_remote_datasource.dart';
import '../../data/repositories/equipment_repository_impl.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/usecases/get_device_by_id_usecase.dart';
import '../../domain/usecases/get_devices_usecase.dart';
import 'equipment_state.dart';

// ─── Các Provider cơ sở hạ tầng (Infrastructure) ──────────────────

/// Provider cung cấp HTTP Client
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

/// Provider cung cấp Network Client
final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(ref.watch(httpClientProvider));
});

/// Provider cung cấp lớp bọc lưu trữ cục bộ (Local Storage Wrapper)
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesFutureProvider.future);
  return LocalStorage(sharedPreferences);
});

// FutureProvider hỗ trợ lấy đối tượng SharedPreferences
final sharedPreferencesFutureProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// ─── Các Provider cung cấp nguồn dữ liệu (DataSource) ───────────────

/// Provider cung cấp nguồn dữ liệu từ xa (Remote DataSource)
final equipmentRemoteDataSourceProvider =
    Provider<EquipmentRemoteDataSource>((ref) {
  return EquipmentRemoteDataSourceImpl(ref.watch(networkClientProvider));
});

/// Provider cung cấp nguồn dữ liệu cục bộ (Local DataSource)
final equipmentLocalDataSourceProvider =
    FutureProvider<EquipmentLocalDataSource>((ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return EquipmentLocalDataSourceImpl(storage);
});

// ─── Provider cung cấp kho lưu trữ (Repository) ───────────────────

/// Provider triển khai Repository (điều phối remote & cache cục bộ)
final equipmentRepositoryProvider =
    FutureProvider<EquipmentRepository>((ref) async {
  final remote = ref.watch(equipmentRemoteDataSourceProvider);
  final local = await ref.watch(equipmentLocalDataSourceProvider.future);
  return EquipmentRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

// ─── Các Provider cung cấp nghiệp vụ (UseCase) ────────────────────

/// UseCase lấy danh sách tất cả các thiết bị
final getDevicesUseCaseProvider =
    FutureProvider<GetDevicesUseCase>((ref) async {
  final repo = await ref.watch(equipmentRepositoryProvider.future);
  return GetDevicesUseCase(repo);
});

/// UseCase lấy thông tin chi tiết một thiết bị theo ID
final getDeviceByIdUseCaseProvider =
    FutureProvider<GetDeviceByIdUseCase>((ref) async {
  final repo = await ref.watch(equipmentRepositoryProvider.future);
  return GetDeviceByIdUseCase(repo);
});

// ─── Các Provider quản lý trạng thái (State) ───────────────────────

/// Provider quản lý trạng thái danh sách thiết bị chính
final devicesStateProvider =
    StateNotifierProvider<DevicesNotifier, EquipmentListState>((ref) {
  return DevicesNotifier(ref);
});

/// Provider quản lý trạng thái chi tiết thiết bị (theo từng ID)
final deviceDetailProvider = StateNotifierProvider.family<DeviceDetailNotifier,
    DeviceDetailState, String>((ref, deviceId) {
  return DeviceDetailNotifier(ref, deviceId);
});

/// Provider quản lý từ khóa tìm kiếm (lưu từ khóa gõ ngay lập tức)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider quản lý từ khóa tìm kiếm đã áp dụng debounce (trễ 400 ms)
final debouncedSearchQueryProvider = Provider<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  final debouncedState = ref.watch(_debouncedSearchStateProvider);
  
  final timer = Timer(const Duration(milliseconds: 400), () {
    ref.read(_debouncedSearchStateProvider.notifier).state = query;
  });
  
  ref.onDispose(() => timer.cancel());
  return debouncedState;
});

final _debouncedSearchStateProvider = StateProvider<String>((ref) => '');

/// Provider lưu trữ danh mục lọc thiết bị đang được chọn
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Enum các tùy chọn sắp xếp thiết bị
enum DeviceSortOption {
  none,
  nameAsc,
  depositLowToHigh,
}

/// Provider lưu tùy chọn sắp xếp đang được chọn
final sortOptionProvider = StateProvider<DeviceSortOption>((ref) => DeviceSortOption.none);

/// Danh sách các danh mục khả dụng được suy ra từ danh sách thiết bị
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final state = ref.watch(devicesStateProvider);
  if (state is EquipmentListLoaded) {
    final categories =
        state.devices.map((d) => d.category).toSet().toList()..sort();
    return ['All', ...categories];
  }
  return ['All'];
});

/// Danh sách thiết bị đã được lọc và sắp xếp dựa trên danh mục, từ khóa tìm kiếm và tùy chọn sắp xếp
final filteredDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final state = ref.watch(devicesStateProvider);
  final query = ref.watch(debouncedSearchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final sortOption = ref.watch(sortOptionProvider);

  if (state is! EquipmentListLoaded) return [];

  var devices = List<DeviceEntity>.from(state.devices);

  // Lọc theo danh mục
  if (category != 'All') {
    devices = devices.where((d) => d.category == category).toList();
  }

  // Lọc theo từ khóa tìm kiếm
  if (query.isNotEmpty) {
    devices = devices
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            d.category.toLowerCase().contains(query))
        .toList();
  }

  // Áp dụng sắp xếp
  switch (sortOption) {
    case DeviceSortOption.none:
      // Giữ nguyên thứ tự ban đầu từ API
      break;
    case DeviceSortOption.nameAsc:
      devices.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case DeviceSortOption.depositLowToHigh:
      devices.sort((a, b) {
        // Xử lý các giá trị tiền cọc bị thiếu một cách nhất quán (đặt ở cuối / giá trị lớn nhất)
        final depA = a.deposit ?? double.maxFinite;
        final depB = b.deposit ?? double.maxFinite;
        return depA.compareTo(depB);
      });
      break;
  }

  return devices;
});

// ─── Provider Danh Sách Theo Dõi (Watchlist Provider) ──────────────

/// Danh sách theo dõi (các ID thiết bị đã được đánh dấu lưu)
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, Set<String>>((ref) {
  return WatchlistNotifier(ref);
});

// ─── Provider Danh Sách So Sánh (Compare List Provider) ─────────────

/// Provider danh sách so sánh (Tối đa 2 thiết bị, được lưu trữ lâu dài)
final compareListProvider =
    StateNotifierProvider<CompareListNotifier, Set<String>>((ref) {
  return CompareListNotifier(ref);
});

class CompareListNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  CompareListNotifier(this._ref) : super({}) {
    _loadCompareList();
  }

  Future<void> _loadCompareList() async {
    try {
      final localStorage = await _ref.read(localStorageProvider.future);
      final ids = localStorage.getString('compare_device_ids');
      if (ids != null && ids.isNotEmpty) {
        state = ids.split(',').toSet();
      }
    } catch (_) {}
  }

  /// Bật/tắt trạng thái so sánh của một thiết bị. Giới hạn tối đa 2 thiết bị.
  /// Trả về false nếu danh sách so sánh đã đầy và người dùng cố gắng thêm thiết bị thứ ba.
  bool toggleCompare(String deviceId) {
    final newSet = Set<String>.from(state);
    if (newSet.contains(deviceId)) {
      newSet.remove(deviceId);
      state = newSet;
      _saveCompareList(newSet);
      return true;
    } else {
      if (newSet.length >= 2) {
        return false; // Áp dụng giới hạn tối đa 2 thiết bị tại đây!
      }
      newSet.add(deviceId);
      state = newSet;
      _saveCompareList(newSet);
      return true;
    }
  }

  Future<void> _saveCompareList(Set<String> newSet) async {
    try {
      final localStorage = await _ref.read(localStorageProvider.future);
      await localStorage.saveString('compare_device_ids', newSet.join(','));
    } catch (_) {}
  }
}

// ─── Bộ quản lý trạng thái (State Notifiers) ───────────────────────

/// Bộ quản lý trạng thái cho danh sách thiết bị
class DevicesNotifier extends StateNotifier<EquipmentListState> {
  final Ref _ref;

  DevicesNotifier(this._ref) : super(const EquipmentListInitial()) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    state = const EquipmentListLoading();

    try {
      final useCase = await _ref.read(getDevicesUseCaseProvider.future);
      final result = await useCase();

      switch (result) {
        case Success<List<DeviceEntity>>():
          if (result.data.isEmpty) {
            state = const EquipmentListEmpty();
          } else {
            state = EquipmentListLoaded(result.data);
          }
        case Error<List<DeviceEntity>>():
          state = EquipmentListError(result.failure.message);
      }
    } catch (e) {
      state = EquipmentListError('Failed to load devices: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    await loadDevices();
  }
}

/// Bộ quản lý trạng thái cho chi tiết thiết bị
class DeviceDetailNotifier extends StateNotifier<DeviceDetailState> {
  final Ref _ref;
  final String _deviceId;

  DeviceDetailNotifier(this._ref, this._deviceId)
      : super(const DeviceDetailLoading()) {
    loadDevice();
  }

  Future<void> loadDevice() async {
    state = const DeviceDetailLoading();

    try {
      final useCase = await _ref.read(getDeviceByIdUseCaseProvider.future);
      final result = await useCase(_deviceId);

      switch (result) {
        case Success<DeviceEntity>():
          state = DeviceDetailLoaded(result.data);
        case Error<DeviceEntity>():
          state = DeviceDetailError(result.failure.message);
      }
    } catch (e) {
      state = DeviceDetailError('Failed to load device: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    await loadDevice();
  }
}

/// Bộ quản lý trạng thái cho danh sách theo dõi (watchlist)
class WatchlistNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  WatchlistNotifier(this._ref) : super({}) {
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      final localStorage = await _ref.read(localStorageProvider.future);
      final ids = localStorage.getString('watchlist_device_ids');
      if (ids != null && ids.isNotEmpty) {
        state = ids.split(',').toSet();
      }
    } catch (_) {
      // Bỏ qua các lỗi khi tải danh sách theo dõi
    }
  }

  Future<void> toggle(String deviceId) async {
    final newSet = Set<String>.from(state);
    if (newSet.contains(deviceId)) {
      newSet.remove(deviceId);
    } else {
      newSet.add(deviceId);
    }
    state = newSet;

    // Lưu trữ lâu dài
    try {
      final localStorage = await _ref.read(localStorageProvider.future);
      await localStorage.saveString(
          'watchlist_device_ids', newSet.join(','));
    } catch (_) {
      // Bỏ qua lỗi lưu trữ lâu dài
    }
  }

  bool isInWatchlist(String deviceId) => state.contains(deviceId);
}

// ─── Provider Quản Lý Tab Đang Hoạt Động (Active Tab Provider) ──────

/// Chỉ số tab đang hoạt động ở thanh điều hướng dưới cùng (Bottom Navigation Bar):
/// 0: Trang chủ, 1: Khám phá, 2: Đã lưu, 3: Hồ sơ
final activeTabProvider = StateNotifierProvider<ActiveTabNotifier, int>((ref) {
  return ActiveTabNotifier();
});

class ActiveTabNotifier extends StateNotifier<int> {
  ActiveTabNotifier() : super(1); // Mặc định là tab Khám phá (1)

  void setTab(int index) {
    state = index;
  }
}

