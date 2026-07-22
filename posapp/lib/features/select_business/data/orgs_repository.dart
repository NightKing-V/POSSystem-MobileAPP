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
    return Organization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Business',
      category: json['category']?.toString() ?? json['type']?.toString() ?? 'Branch',
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
}
