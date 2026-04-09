import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData(String key, dynamic value) async {
    if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is int) {
      return _prefs.setInt(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return _prefs.setStringList(key, value);
    }
    return false;
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static bool getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static Future<bool> removeData(String key) async {
    return _prefs.remove(key);
  }
}
