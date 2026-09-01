import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

/// DTO for creating a Supplier
class CreateSupplierDto {
  final String orgId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? businessRegNo;
  final String? description;

  const CreateSupplierDto({
    required this.orgId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.businessRegNo,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'org_id': orgId,
        'name': name.trim(),
        if (contactPerson?.isNotEmpty == true)
          'contact_person': contactPerson!.trim(),
        if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
        if (email?.isNotEmpty == true) 'email': email!.trim(),
        if (address?.isNotEmpty == true) 'address': address!.trim(),
        if (businessRegNo?.isNotEmpty == true)
          'business_reg_no': businessRegNo!.trim(),
        if (description?.isNotEmpty == true)
          'description': description!.trim(),
      };
}

/// Supplier Model
class SupplierProps {
  final String id;
  final String orgId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? businessRegNo;
  final String? description;

  const SupplierProps({
    required this.id,
    required this.orgId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.businessRegNo,
    this.description,
  });

  factory SupplierProps.fromJson(Map<String, dynamic> json) {
    return SupplierProps(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Supplier',
      contactPerson: json['contact_person']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      businessRegNo: json['business_reg_no']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

/// Suppliers Repository
class SuppliersRepository {
  final ApiClient _apiClient;

  SuppliersRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch suppliers for an organization
  Future<ApiResponse<List<SupplierProps>>> fetchSuppliers({String? orgId}) async {
    final query = orgId != null ? {'orgId': orgId} : null;
    return _apiClient.get<List<SupplierProps>>(
      ApiConstants.suppliers,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => SupplierProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new supplier
  Future<ApiResponse<Map<String, dynamic>>> createSupplier(
    CreateSupplierDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.suppliers,
      body: dto.toJson(),
    );
  }
}

