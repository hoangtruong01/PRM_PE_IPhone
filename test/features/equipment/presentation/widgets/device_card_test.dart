// test/features/equipment/presentation/widgets/device_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/features/equipment/domain/entities/device_entity.dart';
import 'package:campus_equipment_loan/features/equipment/presentation/widgets/device_card.dart';

void main() {
  group('DeviceCard Widget', () {
    const testDevice = DeviceEntity(
      id: '7',
      name: 'MacBook Pro 16',
      category: 'Laptop',
      price: 1849,
      year: 2019,
      deposit: 50,
      cpuModel: 'Intel Core i9',
    );

    Widget createWidget({
      DeviceEntity device = testDevice,
      bool isInWatchlist = false,
      bool isInCompareList = false,
      VoidCallback? onTap,
      VoidCallback? onWatchlistTap,
      VoidCallback? onCompareTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DeviceCard(
            device: device,
            isInWatchlist: isInWatchlist,
            isInCompareList: isInCompareList,
            onTap: onTap ?? () {},
            onWatchlistTap: onWatchlistTap ?? () {},
            onCompareTap: onCompareTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display device name', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('MacBook Pro 16'), findsOneWidget);
    });

    testWidgets('should display category badge', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('LAPTOP'), findsOneWidget);
    });

    testWidgets('should display price and deposit', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.textContaining('\$1849'), findsOneWidget);
      expect(find.textContaining('Deposit \$50'), findsOneWidget);
    });

    testWidgets('should display year info', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Laptop • 2019'), findsOneWidget);
    });

    testWidgets('should handle tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidget(onTap: () => tapped = true));

      await tester.tap(find.byType(DeviceCard));
      expect(tapped, true);
    });

    testWidgets('should show bookmark icon when in watchlist', (tester) async {
      await tester.pumpWidget(createWidget(isInWatchlist: true));

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('should show bookmark outline when not in watchlist',
        (tester) async {
      await tester.pumpWidget(createWidget(isInWatchlist: false));

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('should handle missing price gracefully', (tester) async {
      const deviceNoPrice = DeviceEntity(
        id: '1',
        name: 'Unknown Device',
        category: 'Device',
      );
      await tester.pumpWidget(createWidget(device: deviceNoPrice));

      expect(find.textContaining('N/A'), findsWidgets);
    });
  });
}
