import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/token_storage.dart';

class StaffUserProps {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? roleId;
  final String? locationName;
  final bool isActive;

  const StaffUserProps({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.roleId,
    this.locationName,
    this.isActive = true,
  });

  factory StaffUserProps.fromJson(Map<String, dynamic> json) {
    String? resolvedRole;
    String? resolvedRoleId;

    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final firstRole = (json['roles'] as List).first;
      if (firstRole is Map) {
        resolvedRole = firstRole['name']?.toString() ??
            firstRole['org_role']?['name']?.toString() ??
            firstRole['role']?['name']?.toString();
        resolvedRoleId = firstRole['id']?.toString() ??
            firstRole['role_id']?.toString() ??
            firstRole['org_role_id']?.toString();
      } else if (firstRole is String) {
        resolvedRole = firstRole;
      }
    }

    return StaffUserProps(
      id: json['id']?.toString() ?? '',
      name: json['fullname']?.toString() ??
          json['name']?.toString() ??
          json['full_name']?.toString() ??
          'Staff Member',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: resolvedRole ??
          json['role']?.toString() ??
          json['role_name']?.toString() ??
          'Employee',
      roleId: resolvedRoleId ?? json['role_id']?.toString(),
      locationName: json['location_name']?.toString() ??
          json['location']?.toString(),
      isActive: json['is_active'] != false && json['status'] != 'inactive',
    );
  }
}

class CreateStaffUserDto {
  final String name;
  final String email;
  final String? password;
  final String? phone;
  final String? address;
  final String? roleId;
  final String? locationId;

  const CreateStaffUserDto({
    required this.name,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.roleId,
    this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'fullname': name.trim(),
        'email': email.trim(),
        if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
        if (address?.isNotEmpty == true) 'address': address!.trim(),
      };
}

class InviteMemberDto {
  final String email;
  final String? fullname;
  final String? roleId;
  final List<String>? roleIds;
  final List<String>? locationIds;

  const InviteMemberDto({
    required this.email,
    this.fullname,
    this.roleId,
    this.roleIds,
    this.locationIds,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        if (fullname != null && fullname!.trim().isNotEmpty)
          'fullname': fullname!.trim(),
        if (roleId != null && roleId!.isNotEmpty) 'roleId': roleId,
        if (roleIds != null && roleIds!.isNotEmpty) 'roleIds': roleIds,
        if (locationIds != null && locationIds!.isNotEmpty)
          'locationIds': locationIds,
      };
}

/// Granular permission model
class PermissionItem {
  final String id;
  final String resource;
  final String action;
  final String? description;

  const PermissionItem({
    required this.id,
    required this.resource,
    required this.action,
    this.description,
  });

  factory PermissionItem.fromJson(Map<String, dynamic> json) {
    return PermissionItem(
      id: json['id']?.toString() ?? '',
      resource: json['resource']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resource': resource,
        'action': action,
        if (description != null) 'description': description,
      };

  String get label => description?.isNotEmpty == true
      ? description!
      : '$resource:$action';
}

/// Paginated permissions wrapper
class PaginatedPermissions {
  final List<PermissionItem> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedPermissions({
    required this.items,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 1,
  });

  factory PaginatedPermissions.fromJson(dynamic json,
      {int reqPage = 1, int reqLimit = 20}) {
    if (json is List) {
      final list = json
          .map((e) =>
              PermissionItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return PaginatedPermissions(
        items: list,
        total: list.length,
        page: reqPage,
        limit: reqLimit,
        totalPages: (list.length / reqLimit).ceil().clamp(1, 9999),
      );
    } else if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      List<PermissionItem> list = [];
      final rawItems = map['items'] ??
          map['data'] ??
          map['permissions'] ??
          map['results'];
      if (rawItems is List) {
        list = rawItems
            .map((e) =>
                PermissionItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      final total = (map['total'] ??
              map['totalCount'] ??
              map['count'] ??
              list.length) as int? ??
          list.length;
      final page = (map['page'] ?? map['currentPage'] ?? reqPage) as int? ??
          reqPage;
      final limit =
          (map['limit'] ?? map['pageSize'] ?? reqLimit) as int? ?? reqLimit;
      final totalPages = (map['totalPages'] ??
              map['pageCount'] ??
              (total / (limit > 0 ? limit : 20)).ceil()) as int? ??
          1;

      return PaginatedPermissions(
        items: list,
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
    }
    return const PaginatedPermissions(items: []);
  }
}

/// Link between OrgRole and Permission
class OrgRolePermission {
  final String orgRoleId;
  final String permissionId;
  final PermissionItem? permission;

  const OrgRolePermission({
    required this.orgRoleId,
    required this.permissionId,
    this.permission,
  });

  factory OrgRolePermission.fromJson(Map<String, dynamic> json) {
    PermissionItem? perm;
    if (json['permission'] is Map) {
      perm = PermissionItem.fromJson(
          Map<String, dynamic>.from(json['permission'] as Map));
    }
    return OrgRolePermission(
      orgRoleId: json['org_role_id']?.toString() ??
          json['orgRoleId']?.toString() ??
          '',
      permissionId: json['permission_id']?.toString() ??
          json['permissionId']?.toString() ??
          '',
      permission: perm,
    );
  }
}

/// System Role Model
class SystemRoleProps {
  final String id;
  final String key;
  final String name;

  const SystemRoleProps({
    required this.id,
    required this.key,
    required this.name,
  });

  factory SystemRoleProps.fromJson(Map<String, dynamic> json) {
    return SystemRoleProps(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// OrgRole Model matching backend OrgRole Response Schema
class OrgRoleProps {
  final String id;
  final String? orgId;
  final String? systemRoleId;
  final String name;
  final String? description;
  final bool isSystem;
  final bool isLocationScoped;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final SystemRoleProps? systemRole;
  final List<OrgRolePermission> rolePermissions;
  final int userRolesCount;

  const OrgRoleProps({
    required this.id,
    this.orgId,
    this.systemRoleId,
    required this.name,
    this.description,
    this.isSystem = false,
    this.isLocationScoped = false,
    this.createdAt,
    this.modifiedAt,
    this.systemRole,
    this.rolePermissions = const [],
    this.userRolesCount = 0,
  });

  List<String> get permissions {
    return rolePermissions
        .map((p) => p.permission?.label ?? p.permissionId)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> get permissionIds {
    return rolePermissions
        .map((p) => p.permissionId)
        .where((id) => id.isNotEmpty)
        .toList();
  }

  factory OrgRoleProps.fromJson(Map<String, dynamic> json) {
    List<OrgRolePermission> perms = [];
    if (json['permissions'] is List) {
      for (final item in json['permissions'] as List) {
        if (item is Map) {
          perms.add(OrgRolePermission.fromJson(
              Map<String, dynamic>.from(item)));
        } else if (item is String) {
          perms.add(OrgRolePermission(
            orgRoleId: json['id']?.toString() ?? '',
            permissionId: item,
            permission: PermissionItem(
              id: item,
              resource: item,
              action: 'access',
              description: item,
            ),
          ));
        }
      }
    }

    int count = 0;
    if (json['_count'] is Map && json['_count']['user_roles'] != null) {
      count = int.tryParse(json['_count']['user_roles'].toString()) ?? 0;
    }

    SystemRoleProps? sysRole;
    if (json['system_role'] is Map) {
      sysRole = SystemRoleProps.fromJson(
          Map<String, dynamic>.from(json['system_role'] as Map));
    }

    return OrgRoleProps(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? json['orgId']?.toString(),
      systemRoleId: json['system_role_id']?.toString() ??
          json['systemRoleId']?.toString(),
      name: json['name']?.toString() ?? json['role_name']?.toString() ?? 'Role',
      description: json['description']?.toString(),
      isSystem: json['is_system'] == true,
      isLocationScoped: json['is_location_scoped'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.tryParse(json['modified_at'].toString())
          : null,
      systemRole: sysRole,
      rolePermissions: perms,
      userRolesCount: count,
    );
  }
}

/// Backwards compatibility alias
typedef RoleProps = OrgRoleProps;

/// DTO for Creating Org Role (POST /roles/org)
class CreateRoleDto {
  final String orgId;
  final String name;
  final String? description;
  final String? systemRoleId;
  final bool? isLocationScoped;
  final List<String>? permissionIds;

  const CreateRoleDto({
    required this.orgId,
    required this.name,
    this.description,
    this.systemRoleId,
    this.isLocationScoped,
    this.permissionIds,
  });

  Map<String, dynamic> toJson() => {
        'org_id': orgId,
        'name': name.trim(),
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
        if (systemRoleId != null && systemRoleId!.isNotEmpty)
          'system_role_id': systemRoleId,
        if (isLocationScoped != null)
          'is_location_scoped': isLocationScoped,
        if (permissionIds != null && permissionIds!.isNotEmpty)
          'permissionIds': permissionIds,
      };
}

/// DTO for Updating Org Role (PATCH /roles/org/:id)
class UpdateRoleDto {
  final String? name;
  final String? description;
  final bool? isLocationScoped;
  final List<String>? permissionIds;

  const UpdateRoleDto({
    this.name,
    this.description,
    this.isLocationScoped,
    this.permissionIds,
  });

  Map<String, dynamic> toJson() => {
        if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
        if (description != null) 'description': description!.trim(),
        if (isLocationScoped != null)
          'is_location_scoped': isLocationScoped,
        if (permissionIds != null) 'permissionIds': permissionIds,
      };
}

/// DTO for Assigning Role (POST /roles/org/assign/:orgId/:userId)
class AssignRoleDto {
  final String roleId;

  const AssignRoleDto({required this.roleId});

  Map<String, dynamic> toJson() => {
        'roleId': roleId,
      };
}

/// User Role Assignment Model
class UserRoleAssignment {
  final String id;
  final String userId;
  final String orgId;
  final String roleId;
  final OrgRoleProps? role;

  const UserRoleAssignment({
    required this.id,
    required this.userId,
    required this.orgId,
    required this.roleId,
    this.role,
  });

  factory UserRoleAssignment.fromJson(Map<String, dynamic> json) {
    OrgRoleProps? roleProps;
    if (json['org_role'] is Map) {
      roleProps = OrgRoleProps.fromJson(
          Map<String, dynamic>.from(json['org_role'] as Map));
    } else if (json['role'] is Map) {
      roleProps =
          OrgRoleProps.fromJson(Map<String, dynamic>.from(json['role'] as Map));
    }

    return UserRoleAssignment(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? json['orgId']?.toString() ?? '',
      roleId: json['role_id']?.toString() ?? json['roleId']?.toString() ?? '',
      role: roleProps,
    );
  }
}

class StaffRepository {
  final ApiClient _apiClient;

  StaffRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all staff users for an organization
  Future<ApiResponse<List<StaffUserProps>>> fetchStaffUsers({
    String? orgId,
  }) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    final query = effectiveOrgId != null ? {'orgId': effectiveOrgId} : null;
    return _apiClient.get<List<StaffUserProps>>(
      ApiConstants.users,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => StaffUserProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new staff user or invite org member
  Future<ApiResponse<Map<String, dynamic>>> createStaffUser(
    CreateStaffUserDto dto, {
    String? orgId,
  }) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    if (effectiveOrgId != null && effectiveOrgId.isNotEmpty) {
      final inviteDto = InviteMemberDto(
        email: dto.email,
        fullname: dto.name,
        roleIds: dto.roleId != null && dto.roleId!.isNotEmpty ? [dto.roleId!] : null,
        locationIds: dto.locationId != null && dto.locationId!.isNotEmpty
            ? [dto.locationId!]
            : null,
      );
      final inviteRes = await inviteMember(effectiveOrgId, inviteDto);
      if (inviteRes.isSuccess) {
        return inviteRes;
      }
    }
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.users,
      body: dto.toJson(),
    );
  }

  /// Update user details (PATCH /users/:id)
  Future<ApiResponse<Map<String, dynamic>>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.user(id),
      body: data,
    );
  }

  /// Delete user (DELETE /users/:id)
  Future<ApiResponse<Map<String, dynamic>>> deleteUser(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.user(id),
    );
  }

  /// Invite a member to an organization (POST /orgs/:id/members)
  Future<ApiResponse<Map<String, dynamic>>> inviteMember(
    String orgId,
    InviteMemberDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.orgMembers(orgId),
      body: dto.toJson(),
    );
  }

  /// 1. GET /roles/org: Lists OrgRole records with permissions and user assignment counts
  Future<ApiResponse<List<OrgRoleProps>>> fetchOrgRoles({String? orgId}) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    final query = effectiveOrgId != null ? {'orgId': effectiveOrgId} : null;
    return _apiClient.get<List<OrgRoleProps>>(
      ApiConstants.orgRoles,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => OrgRoleProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// 2. GET /roles/org/:id: Gets a single OrgRole by ID with its permissions and assigned users
  Future<ApiResponse<OrgRoleProps>> fetchOrgRole(String id) async {
    return _apiClient.get<OrgRoleProps>(
      ApiConstants.orgRole(id),
      parser: (json) {
        if (json is Map<String, dynamic>) {
          return OrgRoleProps.fromJson(json);
        }
        return OrgRoleProps.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }

  /// 3. POST /roles/org: Creates a custom OrgRole inside an organization and attaches permissions
  Future<ApiResponse<Map<String, dynamic>>> createOrgRole(
    CreateRoleDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.orgRoles,
      body: dto.toJson(),
    );
  }

  /// 4. PATCH /roles/org/:id: Updates an OrgRole (name, description, is_location_scoped, or replaces permissionIds)
  Future<ApiResponse<Map<String, dynamic>>> updateOrgRole(
    String id,
    UpdateRoleDto dto,
  ) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.orgRole(id),
      body: dto.toJson(),
    );
  }

  /// 5. DELETE /roles/org/:id: Deletes an OrgRole and its permission/user links
  Future<ApiResponse<Map<String, dynamic>>> deleteOrgRole(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.orgRole(id),
    );
  }

  /// 6. GET /roles/org/user-roles/:orgId/:userId: Lists all OrgRole assignments (UserRole) for a user
  Future<ApiResponse<List<UserRoleAssignment>>> fetchUserOrgRoles({
    required String orgId,
    required String userId,
  }) async {
    return _apiClient.get<List<UserRoleAssignment>>(
      ApiConstants.orgUserRoles(orgId, userId),
      parser: (json) {
        if (json is List) {
          return json
              .map((e) =>
                  UserRoleAssignment.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// 6b. GET /roles/user-permissions/:orgId/:userId: Gets effective permissions for a user in an org
  Future<ApiResponse<List<PermissionItem>>> fetchUserPermissions({
    required String orgId,
    required String userId,
  }) async {
    return _apiClient.get<List<PermissionItem>>(
      ApiConstants.userPermissions(orgId, userId),
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => PermissionItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        return [];
      },
    );
  }

  /// 7. POST /roles/assign/:orgId/:userId: Assigns an OrgRole to a user within that organization
  Future<ApiResponse<Map<String, dynamic>>> assignOrgRole({
    required String orgId,
    required String userId,
    required String roleId,
  }) async {
    final dto = AssignRoleDto(roleId: roleId);
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.assignRole(orgId, userId),
      body: dto.toJson(),
    );
  }

  /// 8. DELETE /roles/unassign/:orgId/:userId/:roleId: Removes an OrgRole assignment
  Future<ApiResponse<Map<String, dynamic>>> unassignOrgRole({
    required String orgId,
    required String userId,
    required String roleId,
  }) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.unassignRole(orgId, userId, roleId),
    );
  }

  /// 9. DELETE /roles/unassign/:orgId/:userId: Removes member from organization
  Future<ApiResponse<Map<String, dynamic>>> unassignMember({
    required String orgId,
    required String userId,
  }) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.unassignMember(orgId, userId),
    );
  }

  /// Fetch all system permissions (paginated, searchable, filterable)
  Future<ApiResponse<PaginatedPermissions>> fetchPermissions({
    int page = 1,
    int limit = 20,
    String? search,
    String? resource,
    String? action,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      if (resource?.trim().isNotEmpty == true) 'resource': resource!.trim(),
      if (action?.trim().isNotEmpty == true) 'action': action!.trim(),
    };

    return _apiClient.get<PaginatedPermissions>(
      ApiConstants.permissions,
      queryParams: query,
      parser: (json) => PaginatedPermissions.fromJson(json,
          reqPage: page, reqLimit: limit),
    );
  }

  /// List permissions assigned to an organization role (paginated)
  Future<ApiResponse<PaginatedPermissions>> fetchOrgRolePermissions({
    required String roleId,
    int page = 1,
    int limit = 20,
    String? search,
    String? resource,
    String? action,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (search?.trim().isNotEmpty == true) 'search': search!.trim(),
      if (resource?.trim().isNotEmpty == true) 'resource': resource!.trim(),
      if (action?.trim().isNotEmpty == true) 'action': action!.trim(),
    };

    return _apiClient.get<PaginatedPermissions>(
      ApiConstants.orgRolePermissions(roleId),
      queryParams: query,
      parser: (json) => PaginatedPermissions.fromJson(json,
          reqPage: page, reqLimit: limit),
    );
  }

  /// Attach one or more permissions to an organization role
  Future<ApiResponse<Map<String, dynamic>>> addOrgRolePermissions({
    required String roleId,
    required List<String> permissionIds,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.orgRolePermissions(roleId),
      body: {'permissionIds': permissionIds},
    );
  }

  /// Remove a permission from an organization role
  Future<ApiResponse<Map<String, dynamic>>> removeOrgRolePermission({
    required String roleId,
    required String permissionId,
  }) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.orgRolePermission(roleId, permissionId),
    );
  }

  /// Fetch all system permissions (alias returning flat list)
  Future<ApiResponse<List<PermissionItem>>> fetchAllPermissions() async {
    return _apiClient.get<List<PermissionItem>>(
      ApiConstants.permissionsAll,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => PermissionItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (json is Map && (json['items'] is List || json['data'] is List)) {
          final list = (json['items'] ?? json['data']) as List;
          return list
              .map((e) => PermissionItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        return [];
      },
    );
  }

  /// Fetch system roles
  Future<ApiResponse<List<SystemRoleProps>>> fetchSystemRoles() async {
    return _apiClient.get<List<SystemRoleProps>>(
      ApiConstants.systemRoles,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => SystemRoleProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  // --- Backwards Compatibility Helpers ---
  Future<ApiResponse<List<OrgRoleProps>>> fetchRoles({String? orgId}) =>
      fetchOrgRoles(orgId: orgId);

  Future<ApiResponse<Map<String, dynamic>>> createRole(CreateRoleDto dto) =>
      createOrgRole(dto);

  Future<ApiResponse<Map<String, dynamic>>> deleteRole(String id) =>
      deleteOrgRole(id);
}
