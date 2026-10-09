import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/suppliers_repository.dart';
import './add_edit_supplier_view.dart';

class SuppliersListView extends StatefulWidget {
  const SuppliersListView({super.key, this.orgId, this.isEmbedded = false});

  final String? orgId;
  final bool isEmbedded;

  @override
  State<SuppliersListView> createState() => _SuppliersListViewState();
}

class _SuppliersListViewState extends State<SuppliersListView> {
  final _suppliersRepo = SuppliersRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<SupplierProps> _suppliers = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    final response = await _suppliersRepo.fetchSuppliers(orgId: widget.orgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _suppliers = response.data!;
      }
    });
  }

  List<SupplierProps> get _processedSuppliers {
    var list = _suppliers;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (v) =>
                v.name.toLowerCase().contains(q) ||
                (v.contactPerson != null &&
                    v.contactPerson!.toLowerCase().contains(q)) ||
                (v.phone != null && v.phone!.contains(q)) ||
                (v.email != null && v.email!.toLowerCase().contains(q)),
          )
          .toList();
    }

    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 1:
            comp = (a.contactPerson ?? '').toLowerCase().compareTo((b.contactPerson ?? '').toLowerCase());
            break;
          case 2:
            comp = (a.phone ?? '').compareTo(b.phone ?? '');
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddSupplier([SupplierProps? supplier]) async {
    final isEditing = supplier != null;
    final res = await showResponsiveModal<bool>(
      context: context,
      title: isEditing ? context.tr('suppliers.edit_supplier') : context.tr('suppliers.add_supplier'),
      subtitle: isEditing
          ? supplier.name
          : context.tr('suppliers.register_supplier_subtitle'),
      leadingIcon: const Icon(Icons.local_shipping_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 640,
      builder: (_) => AddEditSupplierView(
        supplier: supplier,
        orgId: widget.orgId,
        isModal: true,
      ),
    );
    if (res == true) {
      _loadSuppliers();
    }
  }

  void _handleDelete(SupplierProps supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('suppliers.delete_supplier_confirm')),
        content: Text('${context.tr('common.confirm_delete_msg')} (${supplier.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('common.cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('common.delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final res = await _suppliersRepo.deleteSupplier(supplier.id);
      if (!mounted) return;

      if (res.isSuccess) {
        setState(() {
          _suppliers.removeWhere((s) => s.id == supplier.id);
        });
        ApiHelper.showSuccessSnackBar(
          context,
          '${supplier.name} ${context.tr('common.deleted_success').toLowerCase()}.',
        );
      } else {
        ApiHelper.showErrorSnackBar(
          context,
          res.errorMessage ?? context.tr('common.error'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _processedSuppliers;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('suppliers.title'),
          subtitle: context.tr('suppliers.subtitle'),
          itemCountText: context.tr('suppliers.count_suppliers', args: {'count': '${list.length}'}),
          searchCtrl: _searchCtrl,
          searchHint: context.tr('common.search'),
          onSearchChanged: (v) => setState(() => _search = v),
          actionLabel: context.tr('suppliers.add_supplier'),
          actionIcon: Icons.add,
          onActionTap: () => _openAddSupplier(),
        ),
        Expanded(
          child: ManagementGridTable<SupplierProps>(
            items: list,
            isLoading: _isLoading,
            emptyTitle: context.tr('suppliers.no_suppliers'),
            emptySubtitle: context.tr('suppliers.no_suppliers_hint'),
            emptyIcon: Icons.local_shipping_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onEdit: (s) => _openAddSupplier(s),
            onDelete: (s) => _handleDelete(s),
            columns: [
              ManagementTableColumn<SupplierProps>(
                label: context.tr('suppliers.supplier_name_header'),
                flex: 3,
                isSortable: true,
                cellBuilder: (s, _) => Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor:
                          AppColors.inkTeal.withValues(alpha: 0.1),
                      child: Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: AppColors.inkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<SupplierProps>(
                label: context.tr('suppliers.contact_person'),
                flex: 2,
                isSortable: true,
                cellBuilder: (s, _) => Text(
                  s.contactPerson ?? '—',
                  style: const TextStyle(fontSize: 13, color: AppColors.ink),
                ),
              ),
              ManagementTableColumn<SupplierProps>(
                label: context.tr('suppliers.phone_email'),
                flex: 3,
                cellBuilder: (s, _) => Text(
                  s.phone ?? s.email ?? '—',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.slate),
                ),
              ),
            ],
            cardBuilder: (ctx, s, _) => InkWell(
              onTap: () => _openAddSupplier(s),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.hairline.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppColors.inkTeal.withValues(alpha: 0.1),
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: AppColors.inkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.contactPerson ?? s.phone ?? s.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.slate),
                        onPressed: () => _openAddSupplier(s),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: context.tr('suppliers.add_supplier'),
      onTap: () => _openAddSupplier(),
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
            Text(
              context.tr('suppliers.title'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
            Text(
              context.tr('suppliers.count_suppliers', args: {'count': '${list.length}'}),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}
