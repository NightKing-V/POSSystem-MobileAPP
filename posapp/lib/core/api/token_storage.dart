/// TokenStorage handles persisting and retrieving the user's JWT / session token.
class TokenStorage {
  static String? _accessToken;
  static Map<String, dynamic>? _currentUser;

  /// Save token in memory
  static Future<void> saveToken(String token) async {
    _accessToken = token;
  }

  /// Retrieve current access token
  static String? getToken() {
    return _accessToken;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Save current user object metadata
  static void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  /// Retrieve current user object metadata
  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  /// Clear token on logout
  static Future<void> clear() async {
    _accessToken = null;
    _currentUser = null;
  }
}
