import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;

  /// Environment variable configured via --dart-define=BACKEND_URL=... or --dart-define-from-file=.env.development
  static const String envBackendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: String.fromEnvironment('BASE_URL', defaultValue: ''),
    ),
  );

  /// Set a custom base URL at runtime if needed
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Platform detection helpers
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  static String get platformName {
    if (kIsWeb) return 'Web (${defaultTargetPlatform.name})';
    return defaultTargetPlatform.name;
  }

  /// Base URL resolution directly from environment variable (or runtime override)
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    return envBackendUrl;
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verify = '/auth/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Orgs / Business endpoints
  static const String orgs = '/orgs';
  static const String orgCategories = '/orgs/categories';

  // Products & Categories endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String brands = '/brands';

  // Sales & Bills endpoints
  static const String bills = '/bills';

  // Customers & Loyalty
  static const String customers = '/customers';
  static const String loyalty = '/loyalty';
  static const String discounts = '/discounts';

  // Suppliers & POs
  static const String suppliers = '/suppliers';
  static const String purchaseOrders = '/purchase-orders';

  // Inventory & Locations
  static const String inventory = '/inventory';

  // Roles & Permissions
  static const String roles = '/roles';
  static const String permissions = '/roles/permissions';
  static const String users = '/users';
}
