import 'package:shared_preferences/shared_preferences.dart';

abstract class SetupService {
  static const String _setupKey = 'hasCompletedSetup';
  static const String _pendingNameKey = 'pendingUserName';
  static const String _pendingEmailKey = 'pendingUserEmail';

  static Future<bool> hasCompletedSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_setupKey) ?? false;
  }

  static Future<void> markSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupKey, true);
  }

  static Future<void> resetSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_setupKey);
  }

  /// Persists name + email entered during registration so the profile
  /// wizard can pre-fill them even after the RegisterScreen is disposed.
  static Future<void> savePendingUserInfo({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingNameKey, name);
    await prefs.setString(_pendingEmailKey, email);
  }

  static Future<({String name, String email})?> getPendingUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_pendingNameKey);
    final email = prefs.getString(_pendingEmailKey);
    if (name == null || name.isEmpty) return null;
    return (name: name, email: email ?? '');
  }

  static Future<void> clearPendingUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingNameKey);
    await prefs.remove(_pendingEmailKey);
  }
}
