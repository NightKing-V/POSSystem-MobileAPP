import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class LocationProps {
  final String id;
  final String name;
  final String type;
  final String? address;
  final String? phone;

  LocationProps({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.phone,
  });

  factory LocationProps.fromJson(Map<String, dynamic> json) {
    return LocationProps(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Default Branch',
      type: json['type']?.toString() ?? 'BRANCH',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class Organization {
  final String id;
  final String name;
  final String? category;
  final String? businessCategoryId;
  final List<LocationProps> locations;

  Organization({
    required this.id,
    required this.name,
    this.category,
    this.businessCategoryId,
    this.locations = const [],
  });

  LocationProps? get primaryLocation =>
      locations.isNotEmpty ? locations.first : null;

  factory Organization.fromJson(Map<String, dynamic> json) {
    List<LocationProps> locs = [];
    if (json.containsKey('locations') && json['locations'] is List) {
      locs = (json['locations'] as List)
          .map((l) => LocationProps.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    String? resolvedCategory;
    String? categoryId;
    if (json.containsKey('business_category') &&
        json['business_category'] is Map) {
      resolvedCategory = json['business_category']['type']?.toString();
      categoryId = json['business_category']['id']?.toString();
    }

    return Organization(
      id: json['id']?.toString() ?? '',
      name: locs.isNotEmpty
          ? locs.first.name
          : json['name']?.toString() ??
              json['title']?.toString() ??
              'Business',
      category: resolvedCategory ??
          json['category']?.toString() ??
          json['type']?.toString() ??
          'Branch',
      businessCategoryId: categoryId ?? json['businesscategory_id']?.toString(),
      locations: locs,
    );
  }
}

/// DTO for Creating Organization
class CreateOrgDto {
  final String? businessName;
  final String? businessType;
  final String? businessCategoryId;
  final String? address;
  final String? phone;

  const CreateOrgDto({
    this.businessName,
    this.businessType,
    this.businessCategoryId,
    this.address,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        if (businessName != null && businessName!.isNotEmpty)
          'businessName': businessName,
        if (businessType != null && businessType!.isNotEmpty)
          'businessType': businessType,
        if (businessCategoryId != null && businessCategoryId!.isNotEmpty)
          'businesscategory_id': businessCategoryId,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
      };
}

class OrgsRepository {
  final ApiClient _apiClient;

  OrgsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch user organizations / businesses from API
  Future<ApiResponse<List<Organization>>> fetchOrganizations() async {
    return _apiClient.get<List<Organization>>(
      ApiConstants.orgs,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => Organization.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new organization / business
  Future<ApiResponse<Map<String, dynamic>>> createOrganization(
    CreateOrgDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.orgs,
      body: dto.toJson(),
    );
  }

  /// Fetch business categories
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchBusinessCategories() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiConstants.orgCategories,
      parser: (json) {
        if (json is List) {
          return json.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      },
    );
  }

  /// Delete an organization / business (temporary/destructive)
  Future<ApiResponse<Map<String, dynamic>>> deleteOrganization(String orgId) async {
    return _apiClient.delete<Map<String, dynamic>>(
      '${ApiConstants.orgs}/$orgId',
    );
  }
}
