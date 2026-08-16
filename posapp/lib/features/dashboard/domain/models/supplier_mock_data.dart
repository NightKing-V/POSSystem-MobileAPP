import '../models/product.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum PurchaseOrderStatus { draft, sent, partiallyReceived, received, cancelled }

extension PurchaseOrderStatusX on PurchaseOrderStatus {
  String get label {
    switch (this) {
      case PurchaseOrderStatus.draft:            return 'Draft';
      case PurchaseOrderStatus.sent:             return 'Sent';
      case PurchaseOrderStatus.partiallyReceived: return 'Partial';
      case PurchaseOrderStatus.received:         return 'Received';
      case PurchaseOrderStatus.cancelled:        return 'Cancelled';
    }
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class Vendor {
  Vendor({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    this.notes = '',
    this.isActive = true,
  });

  final String id;
  String name;
  String contactPerson;
  String phone;
  String email;
  String address;
  String notes;
  bool isActive;
}

class VendorProductLink {
  const VendorProductLink({
    required this.vendorId,
    required this.productId,
    required this.unitCost,
    required this.vendorProductCode,
  });

  final String vendorId;
  final String productId;
  final double unitCost;
  final String vendorProductCode;
}

class PurchaseOrderItem {
  PurchaseOrderItem({
    required this.product,
    required this.orderedQty,
    required this.unitCost,
    this.receivedQty = 0,
    this.isMissing = false,
  });

  final Product product;
  int orderedQty;
  double unitCost;
  int receivedQty;
  bool isMissing;

  double get lineTotal => orderedQty * unitCost;
}

class PurchaseOrder {
  PurchaseOrder({
    required this.id,
    required this.vendorId,
    required this.locationId,
    required this.status,
    required this.expectedDate,
    required this.items,
    this.note = '',
  });

  final String id;
  final String vendorId;
  final String locationId;
  PurchaseOrderStatus status;
  final DateTime expectedDate;
  final List<PurchaseOrderItem> items;
  String note;

  double get orderTotal => items.fold(0.0, (s, i) => s + i.lineTotal);
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

final List<Vendor> mockVendors = [
  Vendor(
    id: 'v1',
    name: 'Lanka Fresh Distributors',
    contactPerson: 'Rohan Mendis',
    phone: '+94 11 234 5678',
    email: 'rohan@lankafresh.lk',
    address: '42 Baseline Rd, Colombo 09',
    notes: 'Delivers every Monday & Thursday.',
    isActive: true,
  ),
  Vendor(
    id: 'v2',
    name: 'Maliban Biscuits PLC',
    contactPerson: 'Samantha Ranasinghe',
    phone: '+94 11 876 5432',
    email: 'orders@maliban.lk',
    address: '15 Negombo Rd, Wattala',
    notes: 'Minimum order Rs. 25,000.',
    isActive: true,
  ),
  Vendor(
    id: 'v3',
    name: 'Cargills Ceylon',
    contactPerson: 'Priya Weerasinghe',
    phone: '+94 77 555 0011',
    email: 'priya@cargills.lk',
    address: '40 York St, Colombo 01',
    notes: '',
    isActive: false,
  ),
];

final List<VendorProductLink> mockVendorLinks = [
  const VendorProductLink(
      vendorId: 'v1', productId: 'p01', unitCost: 380.0, vendorProductCode: 'LF-MILK-1L'),
  const VendorProductLink(
      vendorId: 'v1', productId: 'p03', unitCost: 820.0, vendorProductCode: 'LF-CHEDDAR'),
  const VendorProductLink(
      vendorId: 'v2', productId: 'p08', unitCost: 215.0, vendorProductCode: 'MB-CHIPS-L'),
  const VendorProductLink(
      vendorId: 'v2', productId: 'p12', unitCost: 700.0, vendorProductCode: 'MB-NUTS-250'),
];

final List<PurchaseOrder> mockPurchaseOrders = [
  PurchaseOrder(
    id: 'PO-2026-0001',
    vendorId: 'v1',
    locationId: 'loc1',
    status: PurchaseOrderStatus.received,
    expectedDate: DateTime(2026, 7, 15),
    items: [
      PurchaseOrderItem(
          product: Product.mockProducts[0], orderedQty: 24, unitCost: 380.0, receivedQty: 24),
      PurchaseOrderItem(
          product: Product.mockProducts[2], orderedQty: 10, unitCost: 820.0, receivedQty: 10),
    ],
    note: 'Urgent restock for peak weekend.',
  ),
  PurchaseOrder(
    id: 'PO-2026-0002',
    vendorId: 'v2',
    locationId: 'loc1',
    status: PurchaseOrderStatus.sent,
    expectedDate: DateTime(2026, 8, 20),
    items: [
      PurchaseOrderItem(
          product: Product.mockProducts[7], orderedQty: 50, unitCost: 215.0, receivedQty: 0),
    ],
    note: '',
  ),
  PurchaseOrder(
    id: 'PO-2026-0003',
    vendorId: 'v1',
    locationId: 'loc2',
    status: PurchaseOrderStatus.partiallyReceived,
    expectedDate: DateTime(2026, 8, 10),
    items: [
      PurchaseOrderItem(
          product: Product.mockProducts[0], orderedQty: 12, unitCost: 380.0, receivedQty: 8),
      PurchaseOrderItem(
          product: Product.mockProducts[5], orderedQty: 6, unitCost: 280.0, receivedQty: 0),
    ],
    note: 'Kandy branch restock.',
  ),
  PurchaseOrder(
    id: 'PO-2026-0004',
    vendorId: 'v2',
    locationId: 'loc1',
    status: PurchaseOrderStatus.draft,
    expectedDate: DateTime(2026, 9, 1),
    items: [
      PurchaseOrderItem(
          product: Product.mockProducts[11], orderedQty: 30, unitCost: 700.0, receivedQty: 0),
    ],
    note: '',
  ),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String vendorName(String vendorId) =>
    mockVendors.firstWhere((v) => v.id == vendorId,
        orElse: () => Vendor(
              id: '', name: 'Unknown', contactPerson: '',
              phone: '', email: '', address: '',
            )).name;

int vendorLinkedProductCount(String vendorId) =>
    mockVendorLinks.where((l) => l.vendorId == vendorId).length;
