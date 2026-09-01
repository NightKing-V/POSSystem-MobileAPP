import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

/// DTO for creating Customer
class CreateCustomerDto {
  final String orgId;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? customerType;
  final bool? smsOptOut;
  final bool? isLoyaltyMember;

  const CreateCustomerDto({
    required this.orgId,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    this.customerType,
    this.smsOptOut,
    this.isLoyaltyMember,
  });

  Map<String, dynamic> toJson() => {
        'org_id': orgId,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        if (email?.isNotEmpty == true) 'email': email!.trim(),
        if (address?.isNotEmpty == true) 'address': address!.trim(),
        if (notes?.isNotEmpty == true) 'notes': notes!.trim(),
        'customer_type': ?customerType,
        'sms_opt_out': ?smsOptOut,
        'is_loyalty_member': ?isLoyaltyMember,
      };
}

/// Customer Model
class CustomerProps {
  final String id;
  final String orgId;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isLoyaltyMember;
  final int loyaltyPoints;
  final double totalSpent;
  final int totalVisits;

  const CustomerProps({
    required this.id,
    required this.orgId,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    this.isLoyaltyMember = false,
    this.loyaltyPoints = 0,
    this.totalSpent = 0.0,
    this.totalVisits = 0,
  });

  factory CustomerProps.fromJson(Map<String, dynamic> json) {
    return CustomerProps(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Customer',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
      isLoyaltyMember: json['is_loyalty_member'] == true,
      loyaltyPoints: json['loyalty_points'] is int ? json['loyalty_points'] as int : 0,
      totalSpent: double.tryParse(json['total_spent']?.toString() ?? '0') ?? 0.0,
      totalVisits: json['total_visits'] is int ? json['total_visits'] as int : 0,
    );
  }
}

/// Customers Repository
class CustomersRepository {
  final ApiClient _apiClient;

  CustomersRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all customers for an organization
  Future<ApiResponse<List<CustomerProps>>> fetchCustomers({String? orgId}) async {
    final query = orgId != null ? {'orgId': orgId} : null;
    return _apiClient.get<List<CustomerProps>>(
      ApiConstants.customers,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => CustomerProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new customer
  Future<ApiResponse<Map<String, dynamic>>> createCustomer(
    CreateCustomerDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.customers,
      body: dto.toJson(),
    );
  }
}

