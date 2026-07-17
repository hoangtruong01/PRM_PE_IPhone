// lib/features/equipment/domain/entities/device_entity.dart

/// Domain Entity: Represents a device in the business logic layer.
/// This is a pure Dart class with no framework dependencies.
/// The Entity defines WHAT the business cares about, not HOW data is stored/fetched.
class DeviceEntity {
  final String id;
  final String name;

  // Data from the API's nested "data" object — all optional because
  // the restful-api.dev schema varies per object.
  final String? color;
  final String? capacity;
  final double? price;
  final int? year;
  final String? cpuModel;
  final String? hardDiskSize;
  final String? screenSize;
  final String? description;
  final double? deposit;

  /// Inferred category based on the device name (Laptop, Phone, etc.)
  final String category;

  const DeviceEntity({
    required this.id,
    required this.name,
    this.color,
    this.capacity,
    this.price,
    this.year,
    this.cpuModel,
    this.hardDiskSize,
    this.screenSize,
    this.description,
    this.deposit,
    required this.category,
  });

  /// Display-friendly formatted price
  String get formattedPrice =>
      price != null ? '\$${price!.toStringAsFixed(0)}' : 'N/A';

  /// Display-friendly formatted deposit
  String get formattedDeposit =>
      deposit != null ? '\$${deposit!.toStringAsFixed(0)}' : 'N/A';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeviceEntity(id: $id, name: $name, category: $category)';
}
