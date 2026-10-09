import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage_stub.dart'
    if (dart.library.html) 'token_storage_web.dart'
    if (dart.library.io) 'token_storage_io.dart';

/// TokenStorage handles persisting and retrieving the user's JWT / session token
/// using hardware-backed encrypted storage (FlutterSecureStorage) across Android, iOS,
/// Windows, macOS, Linux, and Web, with SharedPreferences for non-sensitive metadata.
class TokenStorage {
  static const String _kAccessTokenKey = 'kivi_access_token';
  static const String _kCurrentUserKey = 'kivi_current_user';
  static const String _kCurrentOrgIdKey = 'kivi_current_org_id';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(),
    lOptions: LinuxOptions(),
    webOptions: WebOptions(dbName: 'kivi_secure_vault', publicKey: 'kivi_key'),
  );

  static String? _accessToken;
  static Map<String, dynamic>? _currentUser;
  static String? _currentOrgId;
  static bool _isInitialized = false;

  /// Initialize TokenStorage by loading saved token & user metadata from secure vault & disk
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      // 1. Read encrypted access token from FlutterSecureStorage
      try {
        _accessToken = await _secureStorage.read(key: _kAccessTokenKey);
      } catch (_) {
        _accessToken = null;
      }

      // Legacy migration: if secure storage was empty, migrate from plaintext platform storage
      if (_accessToken == null || _accessToken!.isEmpty) {
        final legacyToken = await PlatformStorage.getItem(_kAccessTokenKey);
        if (legacyToken != null && legacyToken.isNotEmpty) {
          _accessToken = legacyToken;
          await _secureStorage.write(key: _kAccessTokenKey, value: legacyToken);
          await PlatformStorage.removeItem(_kAccessTokenKey);
        }
      }

      // 2. Read non-sensitive metadata
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

  /// Save access token in hardware-encrypted secure storage and in-memory cache
  static Future<void> saveToken(String token) async {
    _accessToken = token;
    try {
      await _secureStorage.write(key: _kAccessTokenKey, value: token);
      // Clean up legacy plaintext storage if present
      await PlatformStorage.removeItem(_kAccessTokenKey);
    } catch (_) {}
  }

  /// Retrieve current access token (fast synchronous in-memory read)
  static String? getToken() {
    return _accessToken;
  }

  /// Retrieve current access token directly from secure storage (asynchronous)
  static Future<String?> getSecureToken() async {
    try {
      final token = await _secureStorage.read(key: _kAccessTokenKey);
      if (token != null) _accessToken = token;
      return token ?? _accessToken;
    } catch (_) {
      return _accessToken;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated =>
      _accessToken != null &&
      _accessToken!.trim().isNotEmpty &&
      _accessToken != 'null';

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

  /// Clear secure token and user on logout
  static Future<void> clear() async {
    _accessToken = null;
    _currentUser = null;
    _currentOrgId = null;
    try {
      await _secureStorage.delete(key: _kAccessTokenKey);
      await PlatformStorage.removeItem(_kAccessTokenKey);
      await PlatformStorage.removeItem(_kCurrentUserKey);
      await PlatformStorage.removeItem(_kCurrentOrgIdKey);
    } catch (_) {}
  }
}


