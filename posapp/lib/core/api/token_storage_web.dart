// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web storage adapter directly using browser's window.localStorage
class PlatformStorage {
  static Future<String?> getItem(String key) async {
    try {
      return html.window.localStorage[key];
    } catch (_) {
      return null;
    }
  }

  static Future<void> setItem(String key, String value) async {
    try {
      html.window.localStorage[key] = value;
    } catch (_) {}
  }

  static Future<void> removeItem(String key) async {
    try {
      html.window.localStorage.remove(key);
    } catch (_) {}
  }
}
