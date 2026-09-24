import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class StaffUserProps {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? locationName;
  final bool isActive;

  const StaffUserProps({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.locationName,
    this.isActive = true,
  });

  factory StaffUserProps.fromJson(Map<String, dynamic> json) {
    return StaffUserProps(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'Staff Member',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? json['role_name']?.toString() ?? 'Employee',
      locationName: json['location_name']?.toString() ?? json['location']?.toString(),
      isActive: json['is_active'] != false && json['status'] != 'inactive',
    );
  }
}

class CreateStaffUserDto {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? roleId;
  final String? locationId;

  const CreateStaffUserDto({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.roleId,
    this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
        if (roleId != null) 'role_id': roleId,
        if (locationId != null) 'location_id': locationId,
      };
}

/// Role / Permission Set model
class RoleProps {
  final String id;
  final String name;
  final String? description;
  final List<String> permissions;

  const RoleProps({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  factory RoleProps.fromJson(Map<String, dynamic> json) {
    List<String> perms = [];
    if (json['permissions'] is List) {
      perms = (json['permissions'] as List).map((e) => e.toString()).toList();
    }
    return RoleProps(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['role_name']?.toString() ?? 'Role',
      description: json['description']?.toString(),
      permissions: perms,
    );
  }
}

/// DTO for Creating Role
class CreateRoleDto {
  final String name;
  final String? description;
  final List<String> permissions;

  const CreateRoleDto({
    required this.name,
    this.description,
    this.permissions = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        if (description?.isNotEmpty == true) 'description': description!.trim(),
        'permissions': permissions,
      };
}

class StaffRepository {
  final ApiClient _apiClient;

  StaffRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<StaffUserProps>>> fetchStaffUsers({String? orgId}) async {
    final query = orgId != null ? {'orgId': orgId} : null;
    return _apiClient.get<List<StaffUserProps>>(
      ApiConstants.users,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json.map((e) => StaffUserProps.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createStaffUser(CreateStaffUserDto dto) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.users,
      body: dto.toJson(),
    );
  }

  /// Fetch all roles
  Future<ApiResponse<List<RoleProps>>> fetchRoles({String? orgId}) async {
    final query = orgId != null ? {'orgId': orgId} : null;
    return _apiClient.get<List<RoleProps>>(
      ApiConstants.roles,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json.map((e) => RoleProps.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  /// Create a new role
  Future<ApiResponse<Map<String, dynamic>>> createRole(CreateRoleDto dto) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.roles,
      body: dto.toJson(),
    );
  }
}
