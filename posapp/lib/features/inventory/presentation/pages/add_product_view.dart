import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/category_repository.dart';
import '../widgets/add_category_tab.dart';
import '../widgets/add_product_tab.dart';

/// Clean AddProductView coordinating Add Product and Add Category tabs.
class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryRepository.instance.getAll();
    if (mounted) setState(() => _categories = cats);
  }

  void _switchToCategoryTab() {
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── TabBar ───────────────────────────────────────────────────────
        Container(
          color: AppColors.paper,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
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
                borderSide: BorderSide(color: AppColors.inkTeal, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 0),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Add Product'),
                Tab(text: 'Add Category'),
              ],
            ),
          ),
        ),

        // ── Tab views ────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: product form
              AddProductTab(
                categories: _categories,
                onNewCategoryTap: _switchToCategoryTab,
              ),
              // Tab 2: category form
              AddCategoryTab(
                onCategoryAdded: _loadCategories,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
