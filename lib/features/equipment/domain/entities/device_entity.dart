// lib/features/equipment/domain/entities/device_entity.dart

/// Thực thể Domain (Domain Entity): Đại diện cho một thiết bị trong lớp logic nghiệp vụ.
/// Đây là lớp Dart thuần túy và không phụ thuộc vào bất kỳ framework nào.
/// Lớp Entity này chỉ định nghĩa những gì nghiệp vụ cần quan tâm, chứ không quan tâm cách lưu trữ/truy xuất dữ liệu.
class DeviceEntity {
  final String id;
  final String name;

  // Dữ liệu từ thuộc tính "data" lồng ghép của API — tất cả đều không bắt buộc
  // vì cấu trúc của restful-api.dev thay đổi tùy thuộc vào từng đối tượng thiết bị.
  final String? color;
  final String? capacity;
  final double? price;
  final int? year;
  final String? cpuModel;
  final String? hardDiskSize;
  final String? screenSize;
  final String? description;
  final double? deposit;

  /// Danh mục được suy luận dựa trên tên thiết bị (Laptop, Phone, v.v.)
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

  /// Định dạng giá để hiển thị thân thiện với người dùng
  String get formattedPrice =>
      price != null ? '\$${price!.toStringAsFixed(0)}' : 'N/A';

  /// Định dạng tiền đặt cọc để hiển thị thân thiện với người dùng
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
