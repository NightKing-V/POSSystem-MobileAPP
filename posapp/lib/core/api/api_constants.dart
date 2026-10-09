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

  /// OTP expiration duration in seconds (defaults to 3600 seconds / 1 hour)
  static const int otpExpirySeconds = int.fromEnvironment(
    'OTP_EXPIRY_SECONDS',
    defaultValue: 3600,
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
  static String org(String id) => '/orgs/$id';
  static String orgMembers(String orgId) => '/orgs/$orgId/members';

  // Products & Categories endpoints
  static const String products = '/products';
  static String product(String id) => '/products/$id';
  static const String categories = '/categories';
  static String category(String id) => '/categories/$id';
  static const String brands = '/brands';

  // Sales & Bills endpoints
  static const String bills = '/bills';

  // Customers & Loyalty
  static const String customers = '/customers';
  static String customer(String id) => '/customers/$id';
  static const String loyalty = '/loyalty';
  static const String discounts = '/discounts';

  // Suppliers & POs
  static const String suppliers = '/suppliers';
  static String supplier(String id) => '/suppliers/$id';
  static const String purchaseOrders = '/purchase-orders';
  static String purchaseOrder(String id) => '/purchase-orders/$id';

  // Inventory & Locations
  static const String inventory = '/inventory';
  static String inventoryLocation(String id) => '/inventory/$id';

  // Organization Roles & Memberships endpoints
  static const String roles = '/roles';
  static const String users = '/users';
  static String user(String id) => '/users/$id';

  static String myPermissions(String orgId) => '/roles/my-permissions/$orgId';
  static String role(String id) => '/roles/$id';
  static String rolePermissions(String roleId) => '/roles/$roleId/permissions';
  static String rolePermission(String roleId, String permissionId) =>
      '/roles/$roleId/permissions/$permissionId';
  static String userRoles(String orgId, String userId) =>
      '/roles/user-roles/$orgId/$userId';
  static String userPermissions(String orgId, String userId) =>
      '/roles/user-permissions/$orgId/$userId';
  static String assignRole(String orgId, String userId) =>
      '/roles/assign/$orgId/$userId';
  static String unassignMember(String orgId, String userId) =>
      '/roles/unassign/$orgId/$userId';
  static String unassignRole(String orgId, String userId, String roleId) =>
      '/roles/unassign/$orgId/$userId/$roleId';

  // Admin — System Roles & Global Permissions
  static const String permissions = '/admin/permissions';
  static const String permissionsAll = '/admin/permissions';
  static const String systemRoles = '/admin/system-roles';

  // Backwards compatibility aliases
  static const String orgRoles = '/roles';
  static String orgRole(String id) => '/roles/$id';
  static String orgRolePermissions(String roleId) => '/roles/$roleId/permissions';
  static String orgRolePermission(String roleId, String permissionId) =>
      '/roles/$roleId/permissions/$permissionId';
  static String orgUserRoles(String orgId, String userId) =>
      '/roles/user-roles/$orgId/$userId';
  static String orgAssignRole(String orgId, String userId) =>
      '/roles/assign/$orgId/$userId';
  static String orgUnassignRole(String orgId, String userId, String roleId) =>
      '/roles/unassign/$orgId/$userId/$roleId';
}
