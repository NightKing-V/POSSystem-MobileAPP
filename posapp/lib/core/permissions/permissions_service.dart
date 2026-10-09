import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../api/token_storage_stub.dart'
    if (dart.library.html) '../api/token_storage_web.dart'
    if (dart.library.io) '../api/token_storage_io.dart';
import './app_permissions.dart';

/// PermissionsService manages fetching, caching, and evaluating fine-grained
/// user permissions (`<action>:<resource>`) for the active organization.
class PermissionsService extends ChangeNotifier {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;

  PermissionsService._internal();

  final ApiClient _apiClient = ApiClient();

  Set<String> _permissions = {};
  String? _currentOrgId;
  bool _isLoading = false;

  /// Active cached permissions set
  Set<String> get permissions => Set.unmodifiable(_permissions);

  /// Current active organization ID
  String? get currentOrgId => _currentOrgId;

  /// Whether permissions are currently being fetched from API
  bool get isLoading => _isLoading;

  /// Storage key helper for persistence
  static String _storageKey(String orgId) => 'kivi_permissions_$orgId';

  /// Pre-load cached permissions from local storage with 0ms latency
  Future<void> loadCachedPermissions(String orgId) async {
    _currentOrgId = orgId;
    try {
      final cached = await PlatformStorage.getItem(_storageKey(orgId));
      if (cached != null && cached.isNotEmpty) {
        final decoded = json.decode(cached);
        if (decoded is List) {
          _permissions = decoded.map((e) => e.toString().trim().toLowerCase()).toSet();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  /// Request user permissions for specific organization via GET /roles/my-permissions/:orgId
  /// and persist in cache.
  Future<ApiResponse<Set<String>>> fetchAndCachePermissions(String orgId) async {
    _currentOrgId = orgId;
    _isLoading = true;
    notifyListeners();

    // Load local cache immediately first
    await loadCachedPermissions(orgId);

    final response = await _apiClient.get<Set<String>>(
      ApiConstants.myPermissions(orgId),
      parser: parsePermissionsFromResponse,
    );

    _isLoading = false;

    if (response.isSuccess && response.data != null) {
      _permissions = response.data!;
      // Persist in local storage
      try {
        await PlatformStorage.setItem(
          _storageKey(orgId),
          json.encode(_permissions.toList()),
        );
      } catch (_) {}
      notifyListeners();
    } else {
      notifyListeners();
    }

    return response;
  }

  /// Parses diverse backend permission payload formats into a Set of standardized strings
  static Set<String> parsePermissionsFromResponse(dynamic json) {
    final Set<String> extracted = {};

    void processItem(dynamic item) {
      if (item == null) return;

      if (item is String) {
        final clean = item.trim().toLowerCase();
        if (clean.isNotEmpty) extracted.add(clean);
      } else if (item is Map) {
        // Direct key/name/code/slug/permission attributes
        final directKey = item['key'] ??
            item['name'] ??
            item['code'] ??
            item['slug'] ??
            item['permission'] ??
            item['permission_key'] ??
            item['permissionKey'];

        if (directKey != null && directKey.toString().trim().isNotEmpty) {
          extracted.add(directKey.toString().trim().toLowerCase());
        } else if (item['action'] != null && item['resource'] != null) {
          final action = item['action'].toString().trim().toLowerCase();
          final resource = item['resource'].toString().trim().toLowerCase();
          if (action.isNotEmpty && resource.isNotEmpty) {
            extracted.add('$action:$resource');
          }
        }
      }
    }

    if (json is List) {
      for (final item in json) {
        processItem(item);
      }
    } else if (json is Map) {
      // Check for nested wrappers like { permissions: [...] }, { data: [...] }, { items: [...] }
      final listCandidates = json['permissions'] ??
          json['data'] ??
          json['items'] ??
          json['userPermissions'] ??
          json['rolesPermissions'];

      if (listCandidates is List) {
        for (final item in listCandidates) {
          processItem(item);
        }
      } else if (listCandidates is Map && listCandidates['permissions'] is List) {
        for (final item in listCandidates['permissions']) {
          processItem(item);
        }
      } else {
        // Map where keys might be permissions and values are booleans
        json.forEach((k, v) {
          if (v == true || v == 1 || v == 'true') {
            processItem(k);
          }
        });
      }
    }

    return extracted;
  }

  /// Check if the user has the required permission, considering wildcards and management scope.
  bool hasPermission(String required) {
    final req = required.trim().toLowerCase();

    // 1. 👑 Super Admin / Universal Wildcards
    if (_permissions.contains(AppPermissions.all) ||
        _permissions.contains('*') ||
        _permissions.contains(AppPermissions.manageAll)) {
      return true;
    }

    // 2. Exact match
    if (_permissions.contains(req)) {
      return true;
    }

    // 3. Hierarchical Resource / Action Wildcards
    if (req.contains(':')) {
      final parts = req.split(':');
      final action = parts[0];
      final resource = parts[1];

      // manage:<resource> grants create, read, update, delete on that resource
      if (_permissions.contains('manage:$resource')) {
        return true;
      }

      // *:<resource> grants all actions on that resource
      if (_permissions.contains('*:$resource')) {
        return true;
      }

      // <action>:* grants this action across all resources
      if (_permissions.contains('$action:*')) {
        return true;
      }
    }

    return false;
  }

  /// Check if the user has AT LEAST ONE of the required permissions.
  bool hasAnyPermission(List<String> requiredList) {
    if (requiredList.isEmpty) return true;
    return requiredList.any((p) => hasPermission(p));
  }

  /// Check if the user has ALL of the required permissions.
  bool hasAllPermissions(List<String> requiredList) {
    if (requiredList.isEmpty) return true;
    return requiredList.every((p) => hasPermission(p));
  }

  /// Resource Action Helpers
  bool canManage(String resource) => hasPermission('manage:$resource');
  bool canRead(String resource) => hasPermission('read:$resource');
  bool canCreate(String resource) => hasPermission('create:$resource');
  bool canUpdate(String resource) => hasPermission('update:$resource');
  bool canDelete(String resource) => hasPermission('delete:$resource');

  /// Clear active permissions on logout or business change
  void clear() {
    _permissions = {};
    _currentOrgId = null;
    _isLoading = false;
    notifyListeners();
  }
}
