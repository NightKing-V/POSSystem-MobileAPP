import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/inventory_repository.dart';
import '../../domain/models/product.dart';
import './add_product_view.dart';

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  final _inventoryRepo = InventoryRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final response = await _inventoryRepo.fetchProducts();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _products = response.data!;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> get _processedProducts {
    var list = _products;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
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
            comp = a.sku.toLowerCase().compareTo(b.sku.toLowerCase());
            break;
          case 2:
            comp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
            break;
          case 3:
            comp = a.price.compareTo(b.price);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
  }

  void _openAddEditProduct([Product? product]) async {
    final isEditing = product != null;
    final res = await showResponsiveModal<bool>(
      context: context,
      title: isEditing
          ? context.tr('inventory.edit_product')
          : context.tr('inventory.add_product'),
      subtitle: isEditing
          ? product.name
          : context.tr('inventory.add_product_subtitle'),
      leadingIcon: const Icon(Icons.add_shopping_cart,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 680,
      builder: (_) => const AddProductView(isModal: true),
    );
    if (res == true) {
      _loadProducts();
    }
  }

  void _handleDelete(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('inventory.delete_product_confirm')),
        content: Text('${context.tr('common.confirm_delete_msg')} (${p.name})'),
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
      setState(() {
        _products.removeWhere((item) => item.id == p.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${p.name} ${context.tr('common.deleted_success').toLowerCase()}.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _processedProducts;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('inventory.products'),
          subtitle: context.tr('inventory.subtitle'),
          itemCountText: context.tr('inventory.count_products', args: {'count': '${list.length}'}),
          searchCtrl: _searchCtrl,
          searchHint: context.tr('common.search'),
          onSearchChanged: (v) => setState(() => _search = v),
          actionLabel: context.tr('inventory.add_product'),
          actionIcon: Icons.add,
          onActionTap: () => _openAddEditProduct(),
        ),
        Expanded(
          child: ManagementGridTable<Product>(
            items: list,
            isLoading: _isLoading,
            emptyTitle: context.tr('inventory.no_products'),
            emptySubtitle: context.tr('inventory.no_products_hint'),
            emptyIcon: Icons.inventory_2_outlined,
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
            onEdit: (p) => _openAddEditProduct(p),
            onDelete: (p) => _handleDelete(p),
            columns: [
              ManagementTableColumn<Product>(
                label: context.tr('inventory.product_name_header'),
                flex: 3,
                isSortable: true,
                cellBuilder: (p, _) => Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.inkTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.inkTeal,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.name,
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
              ManagementTableColumn<Product>(
                label: context.tr('inventory.sku'),
                flex: 2,
                isSortable: true,
                cellBuilder: (p, _) => Text(
                  p.sku.isNotEmpty ? p.sku : '—',
                  style: const TextStyle(fontSize: 13, color: AppColors.slate),
                ),
              ),
              ManagementTableColumn<Product>(
                label: context.tr('inventory.category'),
                flex: 2,
                isSortable: true,
                cellBuilder: (p, _) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Text(
                    p.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ManagementTableColumn<Product>(
                label: context.tr('inventory.price'),
                flex: 2,
                isSortable: true,
                alignment: Alignment.centerRight,
                cellBuilder: (p, _) => Text(
                  'Rs. ${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.inkTeal,
                  ),
                ),
              ),
            ],
            cardBuilder: (context, p, _) => Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.hairline.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: InkWell(
                onTap: () => _openAddEditProduct(p),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.inkTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.inkTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.sku.isNotEmpty
                                  ? 'SKU: ${p.sku} · ${p.category}'
                                  : p.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs. ${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: AppColors.inkTeal,
                        ),
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
      label: context.tr('inventory.add_product'),
      onTap: () => _openAddEditProduct(),
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
            Text(context.tr('inventory.products'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text(context.tr('inventory.count_products', args: {'count': '${list.length}'}),
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
