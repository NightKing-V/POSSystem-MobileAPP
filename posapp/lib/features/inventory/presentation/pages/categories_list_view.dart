import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/inventory_repository.dart';
import './add_category_view.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  final _inventoryRepo = InventoryRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<CategoryProps> _categories = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final response = await _inventoryRepo.fetchCategories();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _categories = response.data!;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CategoryProps> get _processedCategories {
    var list = _categories;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
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
            comp = a.level.compareTo(b.level);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
  }

  void _showAddCategoryModal([CategoryProps? cat]) async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: cat != null ? 'Edit Category' : context.tr('inventory.add_category'),
      subtitle: cat != null
          ? cat.name
          : 'Create a new category for grouping products',
      leadingIcon: const Icon(Icons.category_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 500,
      builder: (_) => const AddCategoryView(isModal: true),
    );
    if (res == true) {
      _loadCategories();
    }
  }

  void _handleDelete(CategoryProps cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to remove category "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _categories.removeWhere((c) => c.id == cat.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${cat.name}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _processedCategories;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('inventory.categories'),
          subtitle: 'Inventory Categories & Hierarchy',
          itemCountText:
              '${list.length} ${list.length == 1 ? 'category' : 'categories'}',
          searchCtrl: _searchCtrl,
          searchHint: context.tr('common.search'),
          onSearchChanged: (v) => setState(() => _search = v),
          actionLabel: context.tr('inventory.add_category'),
          actionIcon: Icons.add,
          onActionTap: () => _showAddCategoryModal(),
        ),
        Expanded(
          child: ManagementGridTable<CategoryProps>(
            items: list,
            isLoading: _isLoading,
            emptyTitle: context.tr('inventory.no_categories'),
            emptySubtitle: context.tr('inventory.no_products_hint'),
            emptyIcon: Icons.category_outlined,
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
            onEdit: (c) => _showAddCategoryModal(c),
            onDelete: (c) => _handleDelete(c),
            columns: [
              ManagementTableColumn<CategoryProps>(
                label: 'Category Name',
                flex: 4,
                isSortable: true,
                cellBuilder: (cat, _) => Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.inkTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: AppColors.inkTeal,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<CategoryProps>(
                label: 'Hierarchy Level',
                flex: 2,
                isSortable: true,
                cellBuilder: (cat, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      'Level ${cat.level}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            cardBuilder: (ctx, cat, _) => Card(
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
                onTap: () => _showAddCategoryModal(cat),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.inkTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.category_outlined,
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
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Level ${cat.level}',
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
                        onPressed: () => _showAddCategoryModal(cat),
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
      label: context.tr('inventory.add_category'),
      onTap: () => _showAddCategoryModal(),
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
            Text(context.tr('inventory.categories'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${list.length} categories',
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
