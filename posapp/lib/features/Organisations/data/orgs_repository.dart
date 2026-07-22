import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class Organization {
  final String id;
  final String name;
  final String? category;

  Organization({
    required this.id,
    required this.name,
    this.category,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    String? locationName;
    if (json.containsKey('locations') &&
        json['locations'] is List &&
        (json['locations'] as List).isNotEmpty) {
      locationName = json['locations'][0]['name']?.toString();
    }

    String? resolvedCategory;
    if (json.containsKey('business_category') &&
        json['business_category'] is Map) {
      resolvedCategory = json['business_category']['type']?.toString();
    }

    return Organization(
      id: json['id']?.toString() ?? '',
      name: locationName ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          'Business',
      category: resolvedCategory ??
          json['category']?.toString() ??
          json['type']?.toString() ??
          'Branch',
    );
  }
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
  Future<ApiResponse<Map<String, dynamic>>> createOrganization({
    required String businessName,
    required String businessType,
    String? phone,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.orgs,
      body: {
        'businessName': businessName,
        'businessType': businessType,
        'phone': ?phone,
      },
    );
  }
}
