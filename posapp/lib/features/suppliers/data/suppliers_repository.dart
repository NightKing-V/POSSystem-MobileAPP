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

/// PO Item Props
class PoItemProps {
  final String productId;
  final String productName;
  final int orderedQty;
  final double unitCost;
  final int receivedQty;

  const PoItemProps({
    required this.productId,
    required this.productName,
    required this.orderedQty,
    required this.unitCost,
    this.receivedQty = 0,
  });

  factory PoItemProps.fromJson(Map<String, dynamic> json) {
    return PoItemProps(
      productId: json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? json['name']?.toString() ?? 'Product',
      orderedQty: int.tryParse(json['ordered_qty']?.toString() ?? json['quantity']?.toString() ?? '1') ?? 1,
      unitCost: double.tryParse(json['unit_cost']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      receivedQty: int.tryParse(json['received_qty']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Purchase Order Props
class PurchaseOrderProps {
  final String id;
  final String orgId;
  final String supplierId;
  final String supplierName;
  final String status;
  final double totalAmount;
  final DateTime expectedDate;
  final List<PoItemProps> items;
  final String notes;

  const PurchaseOrderProps({
    required this.id,
    required this.orgId,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.totalAmount,
    required this.expectedDate,
    required this.items,
    this.notes = '',
  });

  factory PurchaseOrderProps.fromJson(Map<String, dynamic> json) {
    List<PoItemProps> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => PoItemProps.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    double total = double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0;
    if (total == 0 && parsedItems.isNotEmpty) {
      total = parsedItems.fold(0.0, (s, i) => s + (i.orderedQty * i.unitCost));
    }

    return PurchaseOrderProps(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId']?.toString() ?? '',
      supplierName: json['supplier_name']?.toString() ?? json['supplier']?['name']?.toString() ?? 'Supplier',
      status: json['status']?.toString() ?? 'DRAFT',
      totalAmount: total,
      expectedDate: json['expected_date'] != null
          ? DateTime.tryParse(json['expected_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: parsedItems,
      notes: json['notes']?.toString() ?? '',
    );
  }
}

/// DTO for Creating a Purchase Order
class CreatePoDto {
  final String orgId;
  final String supplierId;
  final String? locationId;
  final DateTime expectedDate;
  final String? notes;
  final List<Map<String, dynamic>> items;

  const CreatePoDto({
    required this.orgId,
    required this.supplierId,
    this.locationId,
    required this.expectedDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'org_id': orgId,
        'supplier_id': supplierId,
        if (locationId?.isNotEmpty == true) 'location_id': locationId,
        'expected_date': expectedDate.toIso8601String(),
        if (notes?.isNotEmpty == true) 'notes': notes,
        'items': items,
      };
}

/// Suppliers & Purchase Orders Repository
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

  /// Fetch purchase orders
  Future<ApiResponse<List<PurchaseOrderProps>>> fetchPurchaseOrders({
    String? orgId,
    String? supplierId,
  }) async {
    final query = <String, dynamic>{
      'orgId': ?orgId,
      'supplierId': ?supplierId,
    };

    return _apiClient.get<List<PurchaseOrderProps>>(
      ApiConstants.purchaseOrders,
      queryParams: query.isNotEmpty ? query : null,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => PurchaseOrderProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a purchase order
  Future<ApiResponse<Map<String, dynamic>>> createPurchaseOrder(
    CreatePoDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.purchaseOrders,
      body: dto.toJson(),
    );
  }

  /// Update purchase order status (e.g. RECEIVED, SENT)
  Future<ApiResponse<Map<String, dynamic>>> updatePurchaseOrderStatus(
    String id,
    String status,
  ) async {
    return _apiClient.put<Map<String, dynamic>>(
      '${ApiConstants.purchaseOrders}/$id',
      body: {'status': status},
    );
  }
}
