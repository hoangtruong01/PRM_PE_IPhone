// lib/core/storage/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences for type-safe local storage operations.
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  /// Save a string value
  Future<bool> saveString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save a list of strings
  Future<bool> saveStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Remove a key
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
