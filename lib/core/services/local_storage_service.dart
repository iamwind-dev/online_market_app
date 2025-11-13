import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

/// Service để lưu trữ dữ liệu cục bộ sử dụng SharedPreferences
class LocalStorageService {
  late final SharedPreferences _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.info('LocalStorageService initialized');
  }

  // ==================== Token Management ====================

  /// Save authentication token
  Future<bool> saveToken(String token) async {
    try {
      return await _prefs.setString(AppConfig.tokenKey, token);
    } catch (e) {
      AppLogger.error('Error saving token', e);
      return false;
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      return _prefs.getString(AppConfig.tokenKey);
    } catch (e) {
      AppLogger.error('Error getting token', e);
      return null;
    }
  }

  /// Remove authentication token
  Future<bool> removeToken() async {
    try {
      return await _prefs.remove(AppConfig.tokenKey);
    } catch (e) {
      AppLogger.error('Error removing token', e);
      return false;
    }
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String refreshToken) async {
    try {
      return await _prefs.setString(AppConfig.refreshTokenKey, refreshToken);
    } catch (e) {
      AppLogger.error('Error saving refresh token', e);
      return false;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(AppConfig.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Error getting refresh token', e);
      return null;
    }
  }

  /// Remove refresh token
  Future<bool> removeRefreshToken() async {
    try {
      return await _prefs.remove(AppConfig.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Error removing refresh token', e);
      return false;
    }
  }

  // ==================== User Data Management ====================

  /// Save user data
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      return await _prefs.setString(AppConfig.userKey, jsonString);
    } catch (e) {
      AppLogger.error('Error saving user data', e);
      return false;
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs.getString(AppConfig.userKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user data', e);
      return null;
    }
  }

  /// Remove user data
  Future<bool> removeUserData() async {
    try {
      return await _prefs.remove(AppConfig.userKey);
    } catch (e) {
      AppLogger.error('Error removing user data', e);
      return false;
    }
  }

  // ==================== Generic Storage Methods ====================

  /// Save string value
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      AppLogger.error('Error saving string: $key', e);
      return false;
    }
  }

  /// Get string value
  String? getString(String key, {String? defaultValue}) {
    try {
      return _prefs.getString(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error getting string: $key', e);
      return defaultValue;
    }
  }

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      AppLogger.error('Error saving int: $key', e);
      return false;
    }
  }

  /// Get int value
  int? getInt(String key, {int? defaultValue}) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error getting int: $key', e);
      return defaultValue;
    }
  }

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      AppLogger.error('Error saving bool: $key', e);
      return false;
    }
  }

  /// Get bool value
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error getting bool: $key', e);
      return defaultValue;
    }
  }

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      AppLogger.error('Error saving double: $key', e);
      return false;
    }
  }

  /// Get double value
  double? getDouble(String key, {double? defaultValue}) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      AppLogger.error('Error getting double: $key', e);
      return defaultValue;
    }
  }

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      AppLogger.error('Error saving string list: $key', e);
      return false;
    }
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      AppLogger.error('Error getting string list: $key', e);
      return null;
    }
  }

  /// Save object as JSON
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      AppLogger.error('Error saving object: $key', e);
      return false;
    }
  }

  /// Get object from JSON
  Map<String, dynamic>? getObject(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting object: $key', e);
      return null;
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      AppLogger.error('Error removing key: $key', e);
      return false;
    }
  }

  /// Clear all data
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      AppLogger.error('Error clearing storage', e);
      return false;
    }
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}
