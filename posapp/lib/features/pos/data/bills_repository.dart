import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

/// DTO for Bill Tax
class BillTaxDto {
  final String name;
  final double rate;
  final bool? isActive;

  const BillTaxDto({
    required this.name,
    required this.rate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'rate': rate,
        'is_active': ?isActive,
      };
}

/// DTO for Bill Item
class BillItemDto {
  final String productId;
  final int quantity;
  final String? batchId;
  final String? priceId;
  final String? notes;

  const BillItemDto({
    required this.productId,
    required this.quantity,
    this.batchId,
    this.priceId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'batch_id': ?batchId,
        'price_id': ?priceId,
        'notes': ?notes,
      };
}

/// DTO for Bill Payment
class BillPaymentDto {
  final String paymentMethod; // CASH, CARD, BANK_TRANSFER, etc.
  final double amount;
  final String? referenceNo;

  const BillPaymentDto({
    required this.paymentMethod,
    required this.amount,
    this.referenceNo,
  });

  Map<String, dynamic> toJson() => {
        'payment_method': paymentMethod.toUpperCase(),
        'amount': amount,
        if (referenceNo?.isNotEmpty == true) 'reference_no': referenceNo,
      };
}

/// DTO for Creating a Bill in POS
class CreateBillDto {
  final String orgId;
  final String locationId;
  final String cashierId;
  final String? customerId;
  final String? notes;
  final String? couponCode;
  final List<BillTaxDto>? taxes;
  final List<BillItemDto> items;
  final List<BillPaymentDto> payments;

  const CreateBillDto({
    required this.orgId,
    required this.locationId,
    required this.cashierId,
    this.customerId,
    this.notes,
    this.couponCode,
    this.taxes,
    required this.items,
    required this.payments,
  });

  Map<String, dynamic> toJson() => {
        'org_id': orgId,
        'location_id': locationId,
        'cashier_id': cashierId,
        if (customerId?.isNotEmpty == true) 'customer_id': customerId,
        if (notes?.isNotEmpty == true) 'notes': notes,
        if (couponCode?.isNotEmpty == true) 'coupon_code': couponCode,
        if (taxes?.isNotEmpty == true)
          'taxes': taxes!.map((t) => t.toJson()).toList(),
        'items': items.map((i) => i.toJson()).toList(),
        'payments': payments.map((p) => p.toJson()).toList(),
      };
}

/// Sales & Bills Repository
class BillsRepository {
  final ApiClient _apiClient;

  BillsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Create a new bill (Checkout POS)
  Future<ApiResponse<Map<String, dynamic>>> createBill(CreateBillDto dto) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.bills,
      body: dto.toJson(),
    );
  }

  /// Fetch bills with optional filters
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchBills({
    String? orgId,
    String? locationId,
    String? customerId,
  }) async {
    final queryParams = <String, dynamic>{
      'orgId': ?orgId,
      'locationId': ?locationId,
      'customerId': ?customerId,
    };

    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiConstants.bills,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      parser: (json) {
        if (json is List) {
          return json.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      },
    );
  }
}

