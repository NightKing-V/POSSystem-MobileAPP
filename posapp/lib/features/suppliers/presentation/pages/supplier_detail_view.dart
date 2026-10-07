import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../data/suppliers_repository.dart';
import '../../domain/models/supplier_mock_data.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../inventory/domain/models/product.dart';
import '../../../dashboard/presentation/widgets/status_badge.dart';
import './add_edit_supplier_view.dart';
import './create_edit_purchase_order_view.dart';
import './receive_purchase_order_view.dart';
import './link_product_vendor_view.dart';

class SupplierDetailView extends StatefulWidget {
  const SupplierDetailView({super.key, required this.vendor});

  final Vendor vendor;

  @override
  State<SupplierDetailView> createState() => _SupplierDetailViewState();
}

class _SupplierDetailViewState extends State<SupplierDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late bool _isActive;
  List<PurchaseOrder> _orders = [];
  final List<VendorProductLink> _links = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _isActive = widget.vendor.isActive;
    _loadOrders();
  }

  PurchaseOrderStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
        return PurchaseOrderStatus.sent;
      case 'PARTIALLY_RECEIVED':
      case 'PARTIAL':
        return PurchaseOrderStatus.partiallyReceived;
      case 'RECEIVED':
        return PurchaseOrderStatus.received;
      case 'CANCELLED':
        return PurchaseOrderStatus.cancelled;
      default:
        return PurchaseOrderStatus.draft;
    }
  }

  Future<void> _loadOrders() async {
    final repo = SuppliersRepository();
    final res = await repo.fetchPurchaseOrders(supplierId: widget.vendor.id);
    if (res.isSuccess && res.data != null && mounted) {
      setState(() {
        _orders = res.data!
            .where((o) => o.supplierId == widget.vendor.id)
            .map((po) => PurchaseOrder(
                  id: po.id,
                  vendorId: po.supplierId,
                  locationId: 'main_branch',
                  status: _mapStatus(po.status),
                  expectedDate: po.expectedDate,
                  note: po.notes,
                  items: po.items
                      .map((it) => PurchaseOrderItem(
                            product: Product(
                              id: it.productId,
                              name: it.productName,
                              price: it.unitCost,
                              sku: '',
                              category: 'General',
                            ),
                            orderedQty: it.orderedQty,
                            unitCost: it.unitCost,
                            receivedQty: it.receivedQty,
                          ))
                      .toList(),
                ))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(widget.vendor.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.inkTeal),
            onPressed: () => showResponsiveModal<bool>(
              context: context,
              title: context.tr('suppliers.edit_supplier'),
              subtitle: widget.vendor.name,
              leadingIcon: const Icon(Icons.business_outlined, color: AppColors.inkTeal, size: 20),
              maxWidth: 580,
              builder: (_) => AddEditSupplierView(vendor: widget.vendor, isModal: true),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header card ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: _HeaderCard(
                    vendor: widget.vendor,
                    isActive: _isActive,
                    onToggle: (v) => setState(() => _isActive = v),
                  ),
                ),
                // ── TabBar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: TabBar(
                    controller: _tabs,
                    labelColor: AppColors.inkTeal,
                    unselectedLabelColor: AppColors.slate,
                    labelStyle: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 13),
                    indicator: const UnderlineTabIndicator(
                      borderSide:
                          BorderSide(color: AppColors.inkTeal, width: 2.5),
                    ),
                    tabs: [
                      Tab(text: context.tr('suppliers.linked_products_tab', args: {'count': '${_links.length}'})),
                      Tab(text: context.tr('suppliers.purchase_orders_tab', args: {'count': '${_orders.length}'})),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _LinkedProductsTab(
                        links: _links,
                        vendorId: widget.vendor.id,
                        onLinkAdded: () => setState(() {}),
                      ),
                      _PurchaseOrdersTab(
                        orders: _orders,
                        vendor: widget.vendor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.vendor,
    required this.isActive,
    required this.onToggle,
  });

  final Vendor vendor;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.hairline.withAlpha(150), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.inkTeal.withAlpha(18),
                child: Text(vendor.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.inkTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(vendor.contactPerson,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate)),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeThumbColor: AppColors.inkTeal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 10),
          _ContactRow(icon: Icons.phone_outlined, text: vendor.phone),
          const SizedBox(height: 4),
          _ContactRow(icon: Icons.email_outlined, text: vendor.email),
          const SizedBox(height: 4),
          _ContactRow(icon: Icons.location_on_outlined, text: vendor.address),
          if (vendor.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ContactRow(icon: Icons.notes_outlined, text: vendor.notes),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.slate),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: AppColors.slate)),
        ),
      ],
    );
  }
}

// ─── Linked products tab ──────────────────────────────────────────────────────

class _LinkedProductsTab extends StatefulWidget {
  const _LinkedProductsTab({
    required this.links,
    required this.vendorId,
    required this.onLinkAdded,
  });

  final List<VendorProductLink> links;
  final String vendorId;
  final VoidCallback onLinkAdded;

  @override
  State<_LinkedProductsTab> createState() => _LinkedProductsTabState();
}

class _LinkedProductsTabState extends State<_LinkedProductsTab> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final repo = InventoryRepository();
    final res = await repo.fetchProducts();
    if (res.isSuccess && res.data != null && mounted) {
      setState(() => _products = res.data!);
    }
  }

  Product? _product(String id) =>
      _products.cast<Product?>().firstWhere(
          (p) => p?.id == id, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (widget.links.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text(context.tr('suppliers.no_linked_products'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13)),
            ),
          ),
        ...widget.links.map((link) {
          final product = _product(link.productId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LinkedProductTile(link: link, product: product),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.link, size: 16),
          label: Text(context.tr('suppliers.link_a_product')),
          onPressed: () => LinkProductVendorView.show(
            context,
            vendorId: widget.vendorId,
            onLinked: () {
              _loadProducts();
              widget.onLinkAdded();
            },
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.inkTeal,
            side: const BorderSide(color: AppColors.inkTeal, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}

class _LinkedProductTile extends StatelessWidget {
  const _LinkedProductTile({required this.link, required this.product});

  final VendorProductLink link;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.hairline.withAlpha(150), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product?.name ?? link.productId,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(context.tr('suppliers.vendor_code_prefix', args: {'code': link.vendorProductCode}),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate)),
              ],
            ),
          ),
          Text('Rs. ${link.unitCost.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.inkTeal)),
        ],
      ),
    );
  }
}

// ─── Purchase orders tab ──────────────────────────────────────────────────────

class _PurchaseOrdersTab extends StatefulWidget {
  const _PurchaseOrdersTab(
      {required this.orders, required this.vendor});

  final List<PurchaseOrder> orders;
  final Vendor vendor;

  @override
  State<_PurchaseOrdersTab> createState() => _PurchaseOrdersTabState();
}

class _PurchaseOrdersTabState extends State<_PurchaseOrdersTab> {
  List<PurchaseOrderProps> _liveOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final repo = SuppliersRepository();
    final res = await repo.fetchPurchaseOrders(supplierId: widget.vendor.id);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _liveOrders = res.data!;
      }
    });
  }

  PurchaseOrderStatus _mapStatus(String statusStr) {
    switch (statusStr.toUpperCase()) {
      case 'SENT':
        return PurchaseOrderStatus.sent;
      case 'PARTIAL':
      case 'PARTIALLY_RECEIVED':
        return PurchaseOrderStatus.partiallyReceived;
      case 'RECEIVED':
        return PurchaseOrderStatus.received;
      case 'CANCELLED':
        return PurchaseOrderStatus.cancelled;
      default:
        return PurchaseOrderStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_liveOrders.isEmpty && widget.orders.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text(context.tr('suppliers.no_po_for_supplier'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13)),
            ),
          ),
        ..._liveOrders.map((po) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PoHistoryTile(
                po: PurchaseOrder(
                  id: po.id,
                  vendorId: po.supplierId,
                  locationId: 'main_branch',
                  status: _mapStatus(po.status),
                  expectedDate: po.expectedDate,
                  note: po.notes,
                  items: po.items
                      .map((it) => PurchaseOrderItem(
                            product: Product(
                              id: it.productId,
                              name: it.productName,
                              price: it.unitCost,
                              sku: '',
                              category: 'General',
                            ),
                            orderedQty: it.orderedQty,
                            unitCost: it.unitCost,
                          ))
                      .toList(),
                ),
                onUpdated: _loadOrders,
              ),
            )),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: Text(context.tr('suppliers.new_po')),
          onPressed: () async {
            final res = await showResponsiveModal<bool>(
              context: context,
              title: context.tr('suppliers.new_po'),
              subtitle: widget.vendor.name,
              leadingIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.inkTeal, size: 20),
              maxWidth: 680,
              builder: (_) => CreateEditPurchaseOrderView(vendor: widget.vendor, isModal: true),
            );
            if (res == true) _loadOrders();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.inkTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class _PoHistoryTile extends StatelessWidget {
  const _PoHistoryTile({required this.po, this.onUpdated});

  final PurchaseOrder po;
  final VoidCallback? onUpdated;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: po.status == PurchaseOrderStatus.sent ||
              po.status == PurchaseOrderStatus.partiallyReceived
          ? () async {
              final res = await showResponsiveModal<bool>(
                context: context,
                title: context.tr('suppliers.receive_po'),
                subtitle: po.id,
                leadingIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.inkTeal, size: 20),
                maxWidth: 680,
                builder: (_) => ReceivePurchaseOrderView(order: po, isModal: true),
              );
              if (res == true) onUpdated?.call();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.hairline.withAlpha(150), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(po.id,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '${po.expectedDate.day}/${po.expectedDate.month}/${po.expectedDate.year}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate),
                  ),
                ],
              ),
            ),
            StatusBadge(status: po.status),
            const SizedBox(width: 10),
            Text(
              'Rs. ${po.orderTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.inkTeal),
            ),
          ],
        ),
      ),
    );
  }
}
