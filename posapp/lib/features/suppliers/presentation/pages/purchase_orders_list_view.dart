import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/suppliers_repository.dart';
import '../../../dashboard/presentation/widgets/status_badge.dart';
import '../../../inventory/domain/models/product.dart';
import '../../domain/models/supplier_mock_data.dart';
import './create_edit_purchase_order_view.dart';
import './receive_purchase_order_view.dart';

class PurchaseOrdersListView extends StatefulWidget {
  const PurchaseOrdersListView(
      {super.key, this.orgId, this.isEmbedded = false});

  final String? orgId;
  final bool isEmbedded;

  @override
  State<PurchaseOrdersListView> createState() => _PurchaseOrdersListViewState();
}

class _PurchaseOrdersListViewState extends State<PurchaseOrdersListView> {
  final _suppliersRepo = SuppliersRepository();

  String? _vendorFilter;
  String? _statusFilter;
  List<PurchaseOrderProps> _orders = [];
  List<SupplierProps> _suppliers = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final poRes = await _suppliersRepo.fetchPurchaseOrders(orgId: widget.orgId);
    final supRes = await _suppliersRepo.fetchSuppliers(orgId: widget.orgId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (poRes.isSuccess && poRes.data != null) {
        _orders = poRes.data!;
      }
      if (supRes.isSuccess && supRes.data != null) {
        _suppliers = supRes.data!;
      }
    });
  }

  List<PurchaseOrderProps> get _processedOrders {
    var list = _orders.where((po) {
      if (_vendorFilter != null && po.supplierId != _vendorFilter) return false;
      if (_statusFilter != null &&
          po.status.toUpperCase() != _statusFilter!.toUpperCase()) {
        return false;
      }
      return true;
    }).toList();

    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.id.compareTo(b.id);
            break;
          case 1:
            comp = a.supplierName.toLowerCase().compareTo(b.supplierName.toLowerCase());
            break;
          case 2:
            comp = a.expectedDate.compareTo(b.expectedDate);
            break;
          case 3:
            comp = a.items.length.compareTo(b.items.length);
            break;
          case 4:
            comp = a.totalAmount.compareTo(b.totalAmount);
            break;
          case 5:
            comp = a.status.compareTo(b.status);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
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

  void _openCreatePo() async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: 'New Purchase Order',
      subtitle: 'Create a supplier purchase order',
      leadingIcon: const Icon(Icons.receipt_long_rounded,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 720,
      builder: (_) => const CreateEditPurchaseOrderView(isModal: true),
    );
    if (res == true) _loadData();
  }

  void _handlePoTap(PurchaseOrderProps po) {
    if (po.status.toUpperCase() == 'SENT' ||
        po.status.toUpperCase() == 'PARTIAL' ||
        po.status.toUpperCase() == 'PARTIALLY_RECEIVED') {
      showResponsiveModal<bool>(
        context: context,
        title: 'Receive Goods',
        subtitle: po.id,
        leadingIcon: const Icon(Icons.inventory_2_outlined,
            color: AppColors.inkTeal, size: 20),
        maxWidth: 720,
        builder: (_) => ReceivePurchaseOrderView(
          isModal: true,
          order: PurchaseOrder(
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
          ),
        ),
      ).then((res) {
        if (res == true) _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _processedOrders;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: 'Purchase Orders',
          subtitle: 'Stock Replenishment & Vendor Orders',
          itemCountText:
              '${list.length} ${list.length == 1 ? 'order' : 'orders'}',
          filterWidget: _FilterBar(
            vendorFilter: _vendorFilter,
            statusFilter: _statusFilter,
            suppliers: _suppliers,
            onVendorChanged: (v) => setState(() => _vendorFilter = v),
            onStatusChanged: (s) => setState(() => _statusFilter = s),
            onClear: () => setState(() {
              _vendorFilter = null;
              _statusFilter = null;
            }),
          ),
          actionLabel: 'Create PO',
          actionIcon: Icons.add,
          onActionTap: _openCreatePo,
        ),
        Expanded(
          child: ManagementGridTable<PurchaseOrderProps>(
            items: list,
            isLoading: _isLoading,
            emptyTitle: 'No purchase orders',
            emptySubtitle: 'Create your first PO to track stock orders from vendors.',
            emptyIcon: Icons.receipt_long_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            gridMaxCrossAxisExtent: 420,
            gridMainAxisExtent: 130,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onView: (po) => _handlePoTap(po),
            columns: [
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'PO Number',
                flex: 2,
                isSortable: true,
                cellBuilder: (po, _) => Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.inkTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.inkTeal,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'PO #${po.id.length > 6 ? po.id.substring(0, 6) : po.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'Supplier / Vendor',
                flex: 3,
                isSortable: true,
                cellBuilder: (po, _) => Text(
                  po.supplierName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'Expected Date',
                flex: 2,
                isSortable: true,
                cellBuilder: (po, _) => Text(
                  '${po.expectedDate.day.toString().padLeft(2, '0')}/${po.expectedDate.month.toString().padLeft(2, '0')}/${po.expectedDate.year}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.slate),
                ),
              ),
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'Items',
                flex: 1,
                isSortable: true,
                cellBuilder: (po, _) => Text(
                  '${po.items.length} ${po.items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.slate),
                ),
              ),
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'Total Amount',
                flex: 2,
                isSortable: true,
                alignment: Alignment.centerRight,
                cellBuilder: (po, _) => Text(
                  'Rs. ${po.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.inkTeal,
                  ),
                ),
              ),
              ManagementTableColumn<PurchaseOrderProps>(
                label: 'Status',
                width: 130,
                isSortable: true,
                cellBuilder: (po, _) =>
                    StatusBadge(status: _mapStatus(po.status)),
              ),
            ],
            cardBuilder: (ctx, po, _) => _PoListTile(
              po: po,
              statusEnum: _mapStatus(po.status),
              onTap: () => _handlePoTap(po),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: 'Create PO',
      onTap: _openCreatePo,
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: fab,
      );
    }

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
            Text('${list.length} orders',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.vendorFilter,
    required this.statusFilter,
    required this.suppliers,
    required this.onVendorChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  final String? vendorFilter;
  final String? statusFilter;
  final List<SupplierProps> suppliers;
  final ValueChanged<String?> onVendorChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClear;

  bool get _hasFilter => vendorFilter != null || statusFilter != null;

  @override
  Widget build(BuildContext context) {
    String? selectedVendorName;
    if (vendorFilter != null) {
      final s = suppliers.where((e) => e.id == vendorFilter).firstOrNull;
      selectedVendorName = s?.name;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterDropdown<String>(
            label: selectedVendorName ?? 'All Vendors',
            items: suppliers
                .map((v) => DropdownMenuItem(value: v.id, child: Text(v.name)))
                .toList(),
            value: vendorFilter,
            onChanged: onVendorChanged,
          ),
          const SizedBox(width: 8),
          _FilterDropdown<String>(
            label: statusFilter ?? 'All Statuses',
            items: const [
              DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
              DropdownMenuItem(value: 'SENT', child: Text('Sent')),
              DropdownMenuItem(value: 'PARTIAL', child: Text('Partial')),
              DropdownMenuItem(value: 'RECEIVED', child: Text('Received')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
            ],
            value: statusFilter,
            onChanged: onStatusChanged,
          ),
          if (_hasFilter) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.close_rounded, size: 13, color: AppColors.error),
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
              style: const TextStyle(fontSize: 12, color: AppColors.slate)),
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
  const _PoListTile({
    required this.po,
    required this.statusEnum,
    required this.onTap,
  });

  final PurchaseOrderProps po;
  final PurchaseOrderStatus statusEnum;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.hairline.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                      'PO #${po.id.length > 6 ? po.id.substring(0, 6) : po.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  StatusBadge(status: statusEnum),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                po.supplierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(height: 2),
              Text(
                '${po.expectedDate.day}/${po.expectedDate.month}/${po.expectedDate.year}  ·  ${po.items.length} ${po.items.length == 1 ? 'item' : 'items'}',
                style: const TextStyle(fontSize: 11, color: AppColors.slate),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${po.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: AppColors.inkTeal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
