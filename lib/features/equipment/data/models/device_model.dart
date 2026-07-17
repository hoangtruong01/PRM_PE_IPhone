// lib/features/equipment/data/models/device_model.dart

import 'dart:convert';
import '../../domain/entities/device_entity.dart';

/// Data Model: Maps between raw JSON and the Domain Entity.
/// The Model knows about JSON serialization; the Entity does not.
/// This separation means changing the API response format only affects the Model.
class DeviceModel {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  const DeviceModel({
    required this.id,
    required this.name,
    this.data,
  });

  /// Create a DeviceModel from JSON (API response)
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown Device',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  /// Convert to JSON string for local storage
  String toJsonString() => json.encode(toJson());

  /// Create from JSON string (from cache)
  factory DeviceModel.fromJsonString(String jsonString) {
    return DeviceModel.fromJson(json.decode(jsonString));
  }

  /// Infer the category from the device name
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

  /// Helper to safely parse a double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper to safely parse an int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Convert Data Model → Domain Entity
  /// The mapping logic handles optional/missing fields safely.
  DeviceEntity toEntity() {
    final double? price = _parseDouble(data?['price'] ?? data?['Price']);
    // Estimate deposit as ~3% of price, minimum $20
    final double? deposit = price != null
        ? (price * 0.03).clamp(20.0, double.infinity)
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

  /// Convert a list of JSON objects to a list of DeviceModels
  static List<DeviceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .where((json) => json is Map<String, dynamic>)
        .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convert a list of DeviceModels to JSON string for caching
  static String listToJsonString(List<DeviceModel> models) {
    return json.encode(models.map((m) => m.toJson()).toList());
  }

  /// Create a list of DeviceModels from cached JSON string
  static List<DeviceModel> listFromJsonString(String jsonString) {
    final List<dynamic> list = json.decode(jsonString);
    return fromJsonList(list);
  }
}
