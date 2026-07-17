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

// ─── Infrastructure Providers ────────────────────────────────────

/// HTTP Client provider
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

/// Network client provider
final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(ref.watch(httpClientProvider));
});

/// Local storage key-value wrapper provider
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesFutureProvider.future);
  return LocalStorage(sharedPreferences);
});

// Helper future provider to await SharedPreferences
final sharedPreferencesFutureProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// ─── DataSource Providers ────────────────────────────────────────

/// Remote datasource provider
final equipmentRemoteDataSourceProvider =
    Provider<EquipmentRemoteDataSource>((ref) {
  return EquipmentRemoteDataSourceImpl(ref.watch(networkClientProvider));
});

/// Local datasource provider
final equipmentLocalDataSourceProvider =
    FutureProvider<EquipmentLocalDataSource>((ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return EquipmentLocalDataSourceImpl(storage);
});

// ─── Repository Provider ─────────────────────────────────────────

/// Repository implementation provider (coordinates remote & local cache)
final equipmentRepositoryProvider =
    FutureProvider<EquipmentRepository>((ref) async {
  final remote = ref.watch(equipmentRemoteDataSourceProvider);
  final local = await ref.watch(equipmentLocalDataSourceProvider.future);
  return EquipmentRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

// ─── UseCase Providers ───────────────────────────────────────────

/// UseCase to get all devices
final getDevicesUseCaseProvider =
    FutureProvider<GetDevicesUseCase>((ref) async {
  final repo = await ref.watch(equipmentRepositoryProvider.future);
  return GetDevicesUseCase(repo);
});

/// UseCase to get device details by ID
final getDeviceByIdUseCaseProvider =
    FutureProvider<GetDeviceByIdUseCase>((ref) async {
  final repo = await ref.watch(equipmentRepositoryProvider.future);
  return GetDeviceByIdUseCase(repo);
});

// ─── State Providers ──────────────────────────────────────────────

/// Main devices list state provider
final devicesStateProvider =
    StateNotifierProvider<DevicesNotifier, EquipmentListState>((ref) {
  return DevicesNotifier(ref);
});

/// Device detail state provider (per device ID)
final deviceDetailProvider = StateNotifierProvider.family<DeviceDetailNotifier,
    DeviceDetailState, String>((ref, deviceId) {
  return DeviceDetailNotifier(ref, deviceId);
});

/// Search query provider (immediate typing state)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced search query provider (400 ms debounce)
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

/// Selected category filter provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Sorting options enum
enum DeviceSortOption {
  none,
  nameAsc,
  depositLowToHigh,
}

/// Selected sort option provider
final sortOptionProvider = StateProvider<DeviceSortOption>((ref) => DeviceSortOption.none);

/// Available categories derived from devices list
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final state = ref.watch(devicesStateProvider);
  if (state is EquipmentListLoaded) {
    final categories =
        state.devices.map((d) => d.category).toSet().toList()..sort();
    return ['All', ...categories];
  }
  return ['All'];
});

/// Filtered and sorted devices based on category, debounced search, and sort option
final filteredDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final state = ref.watch(devicesStateProvider);
  final query = ref.watch(debouncedSearchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final sortOption = ref.watch(sortOptionProvider);

  if (state is! EquipmentListLoaded) return [];

  var devices = List<DeviceEntity>.from(state.devices);

  // Filter by category
  if (category != 'All') {
    devices = devices.where((d) => d.category == category).toList();
  }

  // Filter by search query
  if (query.isNotEmpty) {
    devices = devices
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            d.category.toLowerCase().contains(query))
        .toList();
  }

  // Apply sorting
  switch (sortOption) {
    case DeviceSortOption.none:
      // Preserves the original API order
      break;
    case DeviceSortOption.nameAsc:
      devices.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case DeviceSortOption.depositLowToHigh:
      devices.sort((a, b) {
        // Handle missing deposit values consistently (placed at the end/max values)
        final depA = a.deposit ?? double.maxFinite;
        final depB = b.deposit ?? double.maxFinite;
        return depA.compareTo(depB);
      });
      break;
  }

  return devices;
});

// ─── Watchlist Provider ──────────────────────────────────────────

/// Watchlist (bookmarked device IDs)
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, Set<String>>((ref) {
  return WatchlistNotifier(ref);
});

// ─── Compare List Provider ───────────────────────────────────────

/// Comparison list provider (At most 2 devices, persisted)
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

  /// Toggles compare status of a device. Enforces at most 2 devices.
  /// Returns false if comparison list is full and user tries to add a third device.
  bool toggleCompare(String deviceId) {
    final newSet = Set<String>.from(state);
    if (newSet.contains(deviceId)) {
      newSet.remove(deviceId);
      state = newSet;
      _saveCompareList(newSet);
      return true;
    } else {
      if (newSet.length >= 2) {
        return false; // Two-device limit enforced here!
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

// ─── State Notifiers ─────────────────────────────────────────────

/// Notifier for the devices list
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

/// Notifier for device detail
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

/// Notifier for watchlist
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
      // Ignore errors loading watchlist
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

    // Persist
    try {
      final localStorage = await _ref.read(localStorageProvider.future);
      await localStorage.saveString(
          'watchlist_device_ids', newSet.join(','));
    } catch (_) {
      // Ignore persistence errors
    }
  }

  bool isInWatchlist(String deviceId) => state.contains(deviceId);
}

// ─── Active Tab Provider ──────────────────────────────────────────

/// Active tab index in bottom navigation bar:
/// 0: Home, 1: Explore, 2: Saved, 3: Profile
final activeTabProvider = StateNotifierProvider<ActiveTabNotifier, int>((ref) {
  return ActiveTabNotifier();
});

class ActiveTabNotifier extends StateNotifier<int> {
  ActiveTabNotifier() : super(1); // Default to Explore (1)

  void setTab(int index) {
    state = index;
  }
}

