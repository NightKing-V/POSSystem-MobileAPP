import 'package:shared_preferences/shared_preferences.dart';

/// IO storage adapter for Android, iOS, Windows, macOS, Linux using SharedPreferences
class PlatformStorage {
  static Future<String?> getItem(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setItem(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  static Future<void> removeItem(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }
}
