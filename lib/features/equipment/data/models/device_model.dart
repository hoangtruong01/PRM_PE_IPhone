// lib/features/equipment/data/models/device_model.dart

import 'dart:convert';
import '../../domain/entities/device_entity.dart';

/// Mô hình dữ liệu (Data Model): Chuyển đổi qua lại giữa JSON thô và thực thể Domain (Entity).
/// Model này hiểu về việc tuần tự hóa JSON; còn Entity thì không.
/// Sự phân tách này giúp việc thay đổi định dạng phản hồi API chỉ ảnh hưởng đến Model.
class DeviceModel {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  const DeviceModel({
    required this.id,
    required this.name,
    this.data,
  });

  /// Tạo một DeviceModel từ JSON (phản hồi API)
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown Device',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  /// Chuyển đổi sang JSON để lưu cache
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  /// Chuyển đổi sang chuỗi JSON để lưu trữ cục bộ
  String toJsonString() => json.encode(toJson());

  /// Tạo từ chuỗi JSON (từ cache)
  factory DeviceModel.fromJsonString(String jsonString) {
    return DeviceModel.fromJson(json.decode(jsonString));
  }

  /// Suy luận danh mục (category) từ tên thiết bị
  static String _inferCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('macbook') ||
        lower.contains('laptop') ||
        lower.contains('notebook')) {
      return 'Laptop';
    } else if (lower.contains('iphone') ||
        lower.contains('galaxy') ||
        lower.contains('pixel') ||
        lower.contains('phone') ||
        lower.contains('huawei') ||
        lower.contains('xiaomi') ||
        lower.contains('oneplus') ||
        lower.contains('nokia')) {
      return 'Phone';
    } else if (lower.contains('ipad') || lower.contains('tablet')) {
      return 'Tablet';
    } else if (lower.contains('watch') || lower.contains('band')) {
      return 'Wearable';
    } else {
      return 'Device';
    }
  }

  /// Hàm hỗ trợ phân tích an toàn kiểu double từ giá trị dynamic
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Hàm hỗ trợ phân tích an toàn kiểu int từ giá trị dynamic
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DeviceEntity toEntity() {
    final double? price = _parseDouble(data?['price'] ?? data?['Price']);
    // Quy tắc tính tiền cọc: $50 cho các thiết bị có giá >= $1000, và $20 cho các thiết bị có giá < $1000
    final double? deposit = price != null
        ? (price >= 1000 ? 50.0 : 20.0)
        : null;

    return DeviceEntity(
      id: id,
      name: name,
      color: data?['color']?.toString() ?? data?['Color']?.toString(),
      capacity: data?['capacity']?.toString() ??
          data?['Capacity']?.toString() ??
          data?['capacity GB']?.toString(),
      price: price,
      year: _parseInt(data?['year'] ?? data?['Year'] ?? data?['generation']?.toString()?.replaceAll(RegExp(r'[^0-9]'), '')),
      cpuModel: data?['CPU model']?.toString() ??
          data?['cpu model']?.toString() ??
          data?['Strap Colour']?.toString(),
      hardDiskSize: data?['Hard disk size']?.toString() ??
          data?['hard disk size']?.toString(),
      screenSize: data?['Screen size']?.toString() ??
          data?['screen size']?.toString(),
      description: data?['Description']?.toString() ??
          data?['description']?.toString(),
      deposit: deposit,
      category: _inferCategory(name),
    );
  }

  /// Chuyển đổi danh sách đối tượng JSON thành danh sách DeviceModel
  static List<DeviceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .where((json) => json is Map<String, dynamic>)
        .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Chuyển đổi danh sách DeviceModel thành chuỗi JSON để lưu cache
  static String listToJsonString(List<DeviceModel> models) {
    return json.encode(models.map((m) => m.toJson()).toList());
  }

  /// Tạo danh sách DeviceModel từ chuỗi JSON đã lưu cache
  static List<DeviceModel> listFromJsonString(String jsonString) {
    final List<dynamic> list = json.decode(jsonString);
    return fromJsonList(list);
  }
}
