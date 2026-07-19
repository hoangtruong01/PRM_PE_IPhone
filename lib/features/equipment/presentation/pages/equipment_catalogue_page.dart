// lib/features/equipment/presentation/pages/equipment_catalogue_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../providers/equipment_providers.dart';
import '../providers/equipment_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/device_card.dart';
import '../widgets/search_bar_widget.dart';

/// Screen A — Device Catalogue
/// Displays a list of devices with search, category filter, and watchlist.
/// Modified to support active tabs: Home, Explore, Saved, Profile.
class EquipmentCataloguePage extends ConsumerWidget {
  const EquipmentCataloguePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final state = ref.watch(devicesStateProvider);
    final categories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredDevices = ref.watch(filteredDevicesProvider);
    final watchlist = ref.watch(watchlistProvider);
    final compareList = ref.watch(compareListProvider);
    final isOffline = ref.watch(isOfflineProvider);

    const activeTeal = Color(0xFF0E9282);

    // Determine AppBar title based on active tab
    String titleText = 'Campus Equipment';
    if (activeTab == 0) titleText = 'Dashboard';
    if (activeTab == 2) titleText = 'Saved Devices';
    if (activeTab == 3) titleText = 'My Profile';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          titleText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: activeTab == 1
            ? [
                // Sort Menu (only shown on Explore tab)
                PopupMenuButton<DeviceSortOption>(
                  icon: const Icon(Icons.sort_rounded, color: Colors.black87),
                  onSelected: (val) {
                    ref.read(sortOptionProvider.notifier).state = val;
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: DeviceSortOption.none,
                      child: Text('Original Order'),
                    ),
                    const PopupMenuItem(
                      value: DeviceSortOption.nameAsc,
                      child: Text('Name A-Z'),
                    ),
                    const PopupMenuItem(
                      value: DeviceSortOption.depositLowToHigh,
                      child: Text('Deposit Low-High'),
                    ),
                  ],
                ),
                // Refresh Button
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
                  onPressed: () {
                    ref.read(devicesStateProvider.notifier).refresh();
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
                  onPressed: () {
                    ref.read(devicesStateProvider.notifier).refresh();
                  },
                ),
              ],
      ),
      body: Column(
        children: [
          // Offline Banner
          if (isOffline) _buildOfflineBanner(),

          // Dynamic Body based on selected tab
          Expanded(
            child: _buildTabBody(
              context,
              ref,
              activeTab,
              state,
              categories,
              selectedCategory,
              filteredDevices,
              watchlist,
              compareList,
              isOffline,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CampusBottomNavBar(),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'Offline Mode — showing cached data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    WidgetRef ref,
    int activeTab,
    EquipmentListState state,
    List<String> categories,
    String selectedCategory,
    List filteredDevices,
    Set<String> watchlist,
    Set<String> compareList,
    bool isOffline,
  ) {
    switch (activeTab) {
      case 0:
        return _buildHomeTab(context, ref, watchlist, compareList, isOffline);
      case 2:
        return _buildSavedTab(context, ref, watchlist, compareList, state);
      case 3:
        return _buildProfileTab(context, ref, isOffline);
      case 1:
      default:
        return _buildExploreTab(
          context,
          ref,
          state,
          categories,
          selectedCategory,
          filteredDevices,
          watchlist,
          compareList,
        );
    }
  }

  // ─── TAB 0: HOME / DASHBOARD ───────────────────────────────────────

  Widget _buildHomeTab(
    BuildContext context,
    WidgetRef ref,
    Set<String> watchlist,
    Set<String> compareList,
    bool isOffline,
  ) {
    const activeTeal = Color(0xFF0E9282);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Campus Loan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: activeTeal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Borrow laptops, phones and tablets easily for your study projects.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics header
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Statistics row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Watchlist',
                  value: '${watchlist.length} devices',
                  icon: Icons.bookmark_rounded,
                  color: const Color(0xFFE1F5FE),
                  textColor: Colors.blue.shade800,
                  onTap: () => ref.read(activeTabProvider.notifier).setTab(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Comparison',
                  value: '${compareList.length} / 2 selected',
                  icon: Icons.compare_arrows_rounded,
                  color: const Color(0xFFF3E5F5),
                  textColor: Colors.purple.shade800,
                  onTap: () {
                    // Show explore tab to select devices
                    ref.read(activeTabProvider.notifier).setTab(1);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Connection status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isOffline ? Colors.orange.shade50 : const Color(0xFFE8F5E9),
                  child: Icon(
                    isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                    color: isOffline ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOffline ? 'Offline Mode' : 'Online Mode',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOffline
                            ? 'Loans will be saved locally and sync later.'
                            : 'Connected to API successfully.',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Explore CTA button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(activeTabProvider.notifier).setTab(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: activeTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'BROWSE EQUIPMENT CATALOGUE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: EXPLORE / CATALOGUE ────────────────────────────────────

  Widget _buildExploreTab(
    BuildContext context,
    WidgetRef ref,
    EquipmentListState state,
    List<String> categories,
    String selectedCategory,
    List filteredDevices,
    Set<String> watchlist,
    Set<String> compareList,
  ) {
    const activeTeal = Color(0xFF0E9282);

    return Column(
      children: [
        const SizedBox(height: 8),

        // Search bar
        SearchBarWidget(
          onChanged: (query) {
            ref.read(searchQueryProvider.notifier).state = query;
          },
        ),

        const SizedBox(height: 12),

        // Category filter chips
        CategoryFilterChips(
          categories: categories,
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            ref.read(selectedCategoryProvider.notifier).state = category;
          },
        ),

        const SizedBox(height: 8),

        // Content area
        Expanded(
          child: _buildContent(
            context,
            ref,
            state,
            filteredDevices,
            watchlist,
            compareList,
          ),
        ),

        // View Watchlist Button (Teal button matching Screen A)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              _showWatchlistBottomSheet(context, ref, watchlist);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'VIEW WATCHLIST',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── TAB 2: SAVED / WATCHLIST ──────────────────────────────────────

  Widget _buildSavedTab(
    BuildContext context,
    WidgetRef ref,
    Set<String> watchlist,
    Set<String> compareList,
    EquipmentListState state,
  ) {
    if (state is! EquipmentListLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E9282)),
        ),
      );
    }

    final savedDevices = state.devices.where((d) => watchlist.contains(d.id)).toList();

    if (savedDevices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No saved devices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on any device card to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(activeTabProvider.notifier).setTab(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9282),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Browse Catalogue'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: savedDevices.length,
      itemBuilder: (context, index) {
        final device = savedDevices[index];
        return DeviceCard(
          device: device,
          isInWatchlist: true,
          isInCompareList: compareList.contains(device.id),
          onTap: () {
            context.push('/device/${device.id}');
          },
          onWatchlistTap: () {
            ref.read(watchlistProvider.notifier).toggle(device.id);
          },
          onCompareTap: () {
            final success = ref.read(compareListProvider.notifier).toggleCompare(device.id);
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You can compare at most 2 devices.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  // ─── TAB 3: PROFILE ────────────────────────────────────────────────

  Widget _buildProfileTab(BuildContext context, WidgetRef ref, bool isOffline) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student details header
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person_rounded, size: 48, color: Color(0xFF0E9282)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Student User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'student@fpt.edu.vn',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // User Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: Column(
              children: [
                _buildInfoRow('Student ID', 'SE1819'),
                const Divider(height: 24, color: Color(0xFFF5F5F5)),
                _buildInfoRow('Status', isOffline ? 'Offline Mode' : 'Connected'),
                const Divider(height: 24, color: Color(0xFFF5F5F5)),
                _buildInfoRow('Campus', 'Hoa Lac Campus'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Loan History',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Mock Loan History Item
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.laptop_mac_rounded, color: Color(0xFF0E9282)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MacBook Pro 16',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Borrowed: 7 days ago',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(color: Color(0xFF0E9282), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  // ─── UTILS & BUILD CONTENT ─────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    EquipmentListState state,
    List filteredDevices,
    Set<String> watchlist,
    Set<String> compareList,
  ) {
    return switch (state) {
      EquipmentListInitial() ||
      EquipmentListLoading() =>
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E9282)),
          ),
        ),
      EquipmentListError(:final message) =>
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(devicesStateProvider.notifier).refresh();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      EquipmentListEmpty() =>
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.devices_other_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No devices found',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      EquipmentListLoaded() =>
        filteredDevices.isEmpty
            ? const Center(
                child: Text(
                  'No matching devices',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              )
            : RefreshIndicator(
                color: const Color(0xFF0E9282),
                onRefresh: () async {
                  await ref.read(devicesStateProvider.notifier).refresh();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    return DeviceCard(
                      device: device,
                      isInWatchlist: watchlist.contains(device.id),
                      isInCompareList: compareList.contains(device.id),
                      onTap: () {
                        context.push('/device/${device.id}');
                      },
                      onWatchlistTap: () {
                        ref.read(watchlistProvider.notifier).toggle(device.id);
                      },
                      onCompareTap: () {
                        final success = ref
                            .read(compareListProvider.notifier)
                            .toggleCompare(device.id);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can compare at most 2 devices.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
    };
  }

  void _showWatchlistBottomSheet(
      BuildContext context, WidgetRef ref, Set<String> watchlist) {
    final state = ref.read(devicesStateProvider);
    if (state is! EquipmentListLoaded) return;

    final watchlistDevices =
        state.devices.where((d) => watchlist.contains(d.id)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentWatchlist = ref.watch(watchlistProvider);
            final currentDevices = watchlistDevices
                .where((d) => currentWatchlist.contains(d.id))
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Watchlist (${currentDevices.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                if (currentDevices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No devices in watchlist'),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentDevices.length,
                      itemBuilder: (context, index) {
                        final device = currentDevices[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E9282).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              device.category,
                              style: const TextStyle(
                                color: Color(0xFF0E9282),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            device.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(device.formattedPrice),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark_remove,
                                color: Color(0xFF0E9282)),
                            onPressed: () {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .toggle(device.id);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/device/${device.id}');
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Custom Persistent Bottom Navigation Bar ──────────────────────────

class CampusBottomNavBar extends ConsumerWidget {
  const CampusBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, ref, 'Home', 0, activeTab == 0),
            _buildNavItem(context, ref, 'Explore', 1, activeTab == 1),
            _buildNavItem(context, ref, 'Saved', 2, activeTab == 2),
            _buildNavItem(context, ref, 'Profile', 3, activeTab == 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, String label, int index, bool isActive) {
    const activeColor = Color(0xFF0E9282);
    const inactiveColor = Colors.grey;

    return InkWell(
      onTap: () {
        ref.read(activeTabProvider.notifier).setTab(index);
        final router = GoRouter.of(context);
        final currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
        if (currentRoute != '/') {
          router.go('/');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
