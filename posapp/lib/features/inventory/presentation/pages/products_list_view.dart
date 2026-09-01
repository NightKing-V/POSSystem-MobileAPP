import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import './add_product_view.dart';

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key});

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('inventory.products'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
            Text('0 products', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: context.tr('common.search'),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate, size: 20),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.slate),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: _EmptyState(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddProductView()),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.tr('inventory.add_product'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.slate.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(context.tr('inventory.no_products'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text(context.tr('inventory.no_products_hint'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
