import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late SharedPreferences _prefs;
  late Box _box;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _box = await Hive.openBox('app_storage');
  }

  // SharedPreferences methods
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // JSON serialization methods
  Future<bool> setObject<T>(String key, T object) async {
    try {
      final jsonString = jsonEncode(object);
      return await setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  // Hive methods for complex data
  Future<void> putHive(String key, dynamic value) async {
    await _box.put(key, value);
  }

  T? getHive<T>(String key) {
    return _box.get(key) as T?;
  }

  Future<void> deleteHive(String key) async {
    await _box.delete(key);
  }

  Future<void> clearHive() async {
    await _box.clear();
  }

  List<T> getAllHive<T>() {
    return _box.values.cast<T>().toList();
  }

  bool containsKeyHive(String key) {
    return _box.containsKey(key);
  }
}
