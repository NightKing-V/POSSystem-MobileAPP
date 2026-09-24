/// In-memory fallback for platforms without html or io storage
class PlatformStorage {
  static final Map<String, String> _memory = {};

  static Future<String?> getItem(String key) async {
    return _memory[key];
  }

  static Future<void> setItem(String key, String value) async {
    _memory[key] = value;
  }

  static Future<void> removeItem(String key) async {
    _memory.remove(key);
  }
}
