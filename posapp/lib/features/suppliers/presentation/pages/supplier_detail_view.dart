import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _isActive = widget.vendor.isActive;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<VendorProductLink> get _links =>
      mockVendorLinks.where((l) => l.vendorId == widget.vendor.id).toList();

  List<PurchaseOrder> get _orders =>
      mockPurchaseOrders.where((o) => o.vendorId == widget.vendor.id).toList();

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
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, 
                builder: (_) =>
                    AddEditSupplierView(vendor: widget.vendor))),
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
                      Tab(text: 'Linked Products (${_links.length})'),
                      Tab(text: 'Purchase Orders (${_orders.length})'),
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

class _LinkedProductsTab extends StatelessWidget {
  const _LinkedProductsTab({
    required this.links,
    required this.vendorId,
    required this.onLinkAdded,
  });

  final List<VendorProductLink> links;
  final String vendorId;
  final VoidCallback onLinkAdded;

  Product? _product(String id) =>
      Product.mockProducts.cast<Product?>().firstWhere(
          (p) => p?.id == id, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (links.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text('No linked products yet.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13)),
            ),
          ),
        ...links.map((link) {
          final product = _product(link.productId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LinkedProductTile(link: link, product: product),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.link, size: 16),
          label: const Text('Link a product'),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LinkProductVendorView(
              vendorId: vendorId,
              onLinked: onLinkAdded,
            ),
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
                Text('Vendor code: ${link.vendorProductCode}',
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

class _PurchaseOrdersTab extends StatelessWidget {
  const _PurchaseOrdersTab(
      {required this.orders, required this.vendor});

  final List<PurchaseOrder> orders;
  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Text('No purchase orders for this supplier.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13)),
            ),
          ),
        ...orders.map((po) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PoHistoryTile(po: po),
            )),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('New Purchase Order'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, 
            builder: (_) => CreateEditPurchaseOrderView(vendor: vendor),
          )),
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
  const _PoHistoryTile({required this.po});

  final PurchaseOrder po;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: po.status == PurchaseOrderStatus.sent ||
              po.status == PurchaseOrderStatus.partiallyReceived
          ? () => Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, 
                builder: (_) => ReceivePurchaseOrderView(order: po),
              ))
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
