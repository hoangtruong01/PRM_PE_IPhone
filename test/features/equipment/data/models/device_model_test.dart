// test/features/equipment/data/models/device_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:campus_equipment_loan/features/equipment/data/models/device_model.dart';

void main() {
  group('DeviceModel', () {
    group('fromJson', () {
      test('should create DeviceModel from complete JSON', () {
        // Arrange
        final json = {
          'id': '7',
          'name': 'Apple MacBook Pro 16',
          'data': {
            'year': 2019,
            'price': 1849.99,
            'CPU model': 'Intel Core i9',
            'Hard disk size': '1 TB',
            'color': 'Silver',
          },
        };

        // Act
        final model = DeviceModel.fromJson(json);

        // Assert
        expect(model.id, '7');
        expect(model.name, 'Apple MacBook Pro 16');
        expect(model.data, isNotNull);
        expect(model.data!['year'], 2019);
        expect(model.data!['price'], 1849.99);
      });

      test('should handle missing data field gracefully', () {
        // Arrange
        final json = {
          'id': '1',
          'name': 'Google Pixel 6 Pro',
          'data': null,
        };

        // Act
        final model = DeviceModel.fromJson(json);

        // Assert
        expect(model.id, '1');
        expect(model.name, 'Google Pixel 6 Pro');
        expect(model.data, isNull);
      });

      test('should handle non-map data field', () {
        // Arrange
        final json = {
          'id': '2',
          'name': 'Some Device',
          'data': 'not a map',
        };

        // Act
        final model = DeviceModel.fromJson(json);

        // Assert
        expect(model.data, isNull);
      });

      test('should handle missing name field', () {
        // Arrange
        final json = {
          'id': '3',
        };

        // Act
        final model = DeviceModel.fromJson(json as Map<String, dynamic>);

        // Assert
        expect(model.name, 'Unknown Device');
      });
    });

    group('toEntity', () {
      test('should correctly map to DeviceEntity with full data', () {
        // Arrange
        final model = DeviceModel.fromJson({
          'id': '7',
          'name': 'Apple MacBook Pro 16',
          'data': {
            'year': 2019,
            'price': 1849.99,
            'CPU model': 'Intel Core i9',
            'Hard disk size': '1 TB',
            'color': 'Silver',
          },
        });

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, '7');
        expect(entity.name, 'Apple MacBook Pro 16');
        expect(entity.category, 'Laptop');
        expect(entity.year, 2019);
        expect(entity.price, 1849.99);
        expect(entity.cpuModel, 'Intel Core i9');
        expect(entity.hardDiskSize, '1 TB');
        expect(entity.color, 'Silver');
        expect(entity.deposit, isNotNull);
      });

      test('should infer category as Phone for phone devices', () {
        final model = DeviceModel.fromJson({
          'id': '1',
          'name': 'Samsung Galaxy S21',
          'data': {'price': 799},
        });

        final entity = model.toEntity();
        expect(entity.category, 'Phone');
      });

      test('should infer category as Laptop for laptop devices', () {
        final model = DeviceModel.fromJson({
          'id': '2',
          'name': 'Dell Notebook XPS',
          'data': {'price': 1299},
        });

        final entity = model.toEntity();
        expect(entity.category, 'Laptop');
      });

      test('should handle null data in entity conversion', () {
        final model = DeviceModel.fromJson({
          'id': '3',
          'name': 'Unknown Gadget',
          'data': null,
        });

        final entity = model.toEntity();
        expect(entity.id, '3');
        expect(entity.price, isNull);
        expect(entity.year, isNull);
        expect(entity.cpuModel, isNull);
        expect(entity.deposit, isNull);
        expect(entity.category, 'Device');
      });

      test('should calculate deposit as ~3% of price with \$20 minimum', () {
        // Price = 500, 3% = 15, clamped to minimum 20
        final model1 = DeviceModel.fromJson({
          'id': '4',
          'name': 'Cheap Phone',
          'data': {'price': 500},
        });
        expect(model1.toEntity().deposit, 20.0);

        // Price = 1849, 3% = 55.47
        final model2 = DeviceModel.fromJson({
          'id': '5',
          'name': 'MacBook Pro',
          'data': {'price': 1849},
        });
        expect(model2.toEntity().deposit, greaterThan(50));
      });
    });

    group('serialization', () {
      test('should serialize and deserialize list correctly', () {
        final models = [
          DeviceModel.fromJson({
            'id': '1',
            'name': 'Device 1',
            'data': {'price': 999}
          }),
          DeviceModel.fromJson({
            'id': '2',
            'name': 'Device 2',
            'data': {'price': 599}
          }),
        ];

        final jsonString = DeviceModel.listToJsonString(models);
        final restored = DeviceModel.listFromJsonString(jsonString);

        expect(restored.length, 2);
        expect(restored[0].id, '1');
        expect(restored[1].id, '2');
        expect(restored[0].name, 'Device 1');
        expect(restored[1].name, 'Device 2');
      });
    });
  });
}
