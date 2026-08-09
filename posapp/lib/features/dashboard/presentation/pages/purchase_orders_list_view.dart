import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';
import '../widgets/status_badge.dart';
import 'create_edit_purchase_order_view.dart';
import 'receive_purchase_order_view.dart';

class PurchaseOrdersListView extends StatefulWidget {
  const PurchaseOrdersListView({super.key});

  @override
  State<PurchaseOrdersListView> createState() =>
      _PurchaseOrdersListViewState();
}

class _PurchaseOrdersListViewState extends State<PurchaseOrdersListView> {
  String? _vendorFilter;
  PurchaseOrderStatus? _statusFilter;

  List<PurchaseOrder> get _filtered {
    return mockPurchaseOrders.where((po) {
      if (_vendorFilter != null && po.vendorId != _vendorFilter) return false;
      if (_statusFilter != null && po.status != _statusFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Purchase Orders',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${mockPurchaseOrders.length} orders',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                // ── Filter chips ─────────────────────────────────────────
                _FilterBar(
                  vendorFilter: _vendorFilter,
                  statusFilter: _statusFilter,
                  onVendorChanged: (v) =>
                      setState(() => _vendorFilter = v),
                  onStatusChanged: (s) =>
                      setState(() => _statusFilter = s),
                  onClear: () => setState(() {
                    _vendorFilter = null;
                    _statusFilter = null;
                  }),
                ),
                Expanded(
                  child: orders.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(24, 8, 24, 100),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _PoListTile(
                            po: orders[i],
                            onTap: () {
                              if (orders[i].status ==
                                      PurchaseOrderStatus.sent ||
                                  orders[i].status ==
                                      PurchaseOrderStatus.partiallyReceived) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      ReceivePurchaseOrderView(
                                          order: orders[i]),
                                ));
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const CreateEditPurchaseOrderView(),
        )),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create PO',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.vendorFilter,
    required this.statusFilter,
    required this.onVendorChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  final String? vendorFilter;
  final PurchaseOrderStatus? statusFilter;
  final ValueChanged<String?> onVendorChanged;
  final ValueChanged<PurchaseOrderStatus?> onStatusChanged;
  final VoidCallback onClear;

  bool get _hasFilter => vendorFilter != null || statusFilter != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        children: [
          // Vendor filter
          _FilterDropdown<String>(
            label: vendorFilter == null
                ? 'All Vendors'
                : vendorName(vendorFilter!),
            items: mockVendors
                .map((v) => DropdownMenuItem(value: v.id, child: Text(v.name)))
                .toList(),
            value: vendorFilter,
            onChanged: onVendorChanged,
          ),
          const SizedBox(width: 8),
          // Status filter
          _FilterDropdown<PurchaseOrderStatus>(
            label: statusFilter == null
                ? 'All Statuses'
                : statusFilter!.label,
            items: PurchaseOrderStatus.values
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            value: statusFilter,
            onChanged: onStatusChanged,
          ),
          if (_hasFilter) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withAlpha(50), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.close_rounded,
                        size: 13, color: AppColors.error),
                    SizedBox(width: 4),
                    Text('Clear',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.slate)),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink),
          iconSize: 16,
          onChanged: onChanged,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                label.startsWith('All') ? label : 'All',
                style: const TextStyle(color: AppColors.slate),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _PoListTile extends StatelessWidget {
  const _PoListTile({required this.po, required this.onTap});

  final PurchaseOrder po;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.hairline.withAlpha(150), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(po.id,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                StatusBadge(status: po.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(vendorName(po.vendorId),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.slate)),
            Text(
              '${po.expectedDate.day}/${po.expectedDate.month}/${po.expectedDate.year}  ·  ${po.items.length} ${po.items.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontSize: 11, color: AppColors.slate),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${po.orderTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.inkTeal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.slate.withAlpha(80)),
            const SizedBox(height: 16),
            Text('No purchase orders',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Create your first PO to track\nstock orders from vendors.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
