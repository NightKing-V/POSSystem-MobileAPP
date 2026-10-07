import 'package:flutter/widgets.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../inventory/domain/models/product.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum PurchaseOrderStatus { draft, sent, partiallyReceived, received, cancelled }

extension PurchaseOrderStatusX on PurchaseOrderStatus {
  String localizedLabel(BuildContext context) {
    switch (this) {
      case PurchaseOrderStatus.draft:             return context.tr('suppliers.status_draft');
      case PurchaseOrderStatus.sent:              return context.tr('suppliers.status_sent');
      case PurchaseOrderStatus.partiallyReceived: return context.tr('suppliers.status_partial');
      case PurchaseOrderStatus.received:          return context.tr('suppliers.status_received');
      case PurchaseOrderStatus.cancelled:         return context.tr('suppliers.status_cancelled');
    }
  }

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

// ─── Data Stores ─────────────────────────────────────────────────────────────

final List<Vendor> mockVendors = [];

final List<VendorProductLink> mockVendorLinks = [];

final List<PurchaseOrder> mockPurchaseOrders = [];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String vendorName(String vendorId) =>
    mockVendors.firstWhere((v) => v.id == vendorId,
        orElse: () => Vendor(
              id: '', name: 'Unknown', contactPerson: '',
              phone: '', email: '', address: '',
            )).name;

int vendorLinkedProductCount(String vendorId) =>
    mockVendorLinks.where((l) => l.vendorId == vendorId).length;
