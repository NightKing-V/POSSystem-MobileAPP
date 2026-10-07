import 'dart:convert';
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_io.dart';

/// TokenStorage handles persisting and retrieving the user's JWT / session token
/// across Flutter Web (browser localStorage) and Mobile/Desktop (SharedPreferences).
class TokenStorage {
  static const String _kAccessTokenKey = 'kivi_access_token';
  static const String _kCurrentUserKey = 'kivi_current_user';
  static const String _kCurrentOrgIdKey = 'kivi_current_org_id';

  static String? _accessToken;
  static Map<String, dynamic>? _currentUser;
  static String? _currentOrgId;
  static bool _isInitialized = false;

  /// Initialize TokenStorage by loading saved token & user metadata from disk / localStorage
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      _accessToken = await PlatformStorage.getItem(_kAccessTokenKey);
      _currentOrgId = await PlatformStorage.getItem(_kCurrentOrgIdKey);
      final userJson = await PlatformStorage.getItem(_kCurrentUserKey);
      if (userJson != null && userJson.isNotEmpty) {
        _currentUser = json.decode(userJson) as Map<String, dynamic>?;
      }
      _isInitialized = true;
    } catch (_) {
      _isInitialized = true;
    }
  }

  /// Save token in memory and persistent storage
  static Future<void> saveToken(String token) async {
    _accessToken = token;
    try {
      await PlatformStorage.setItem(_kAccessTokenKey, token);
    } catch (_) {}
  }

  /// Retrieve current access token
  static String? getToken() {
    return _accessToken;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Save current user object metadata in memory and persistent storage
  static Future<void> setCurrentUser(Map<String, dynamic> user) async {
    _currentUser = user;
    try {
      await PlatformStorage.setItem(_kCurrentUserKey, json.encode(user));
    } catch (_) {}
  }

  /// Retrieve current user object metadata
  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  /// Save current active organization ID
  static Future<void> setCurrentOrgId(String orgId) async {
    _currentOrgId = orgId;
    try {
      await PlatformStorage.setItem(_kCurrentOrgIdKey, orgId);
    } catch (_) {}
  }

  /// Retrieve current active organization ID
  static String? get currentOrgId => _currentOrgId;

  /// Clear token and user on logout
  static Future<void> clear() async {
    _accessToken = null;
    _currentUser = null;
    _currentOrgId = null;
    try {
      await PlatformStorage.removeItem(_kAccessTokenKey);
      await PlatformStorage.removeItem(_kCurrentUserKey);
      await PlatformStorage.removeItem(_kCurrentOrgIdKey);
    } catch (_) {}
  }
}


