// lib/core/storage/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp bọc SharedPreferences để thực hiện các thao tác lưu trữ cục bộ an toàn về kiểu dữ liệu (type-safe).
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  /// Lưu một giá trị kiểu String
  Future<bool> saveString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Lấy một giá trị kiểu String
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Lưu danh sách các chuỗi (List<String>)
  Future<bool> saveStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  /// Lấy danh sách các chuỗi (List<String>)
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Xóa một khóa (key)
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Kiểm tra sự tồn tại của khóa (key)
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
