import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);

  static Future<void> clear() => _prefs.clear();
}
