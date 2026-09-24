import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../inventory/domain/models/product.dart';

/// Modal sheet/dialog for searching and selecting products for a purchase order.
class PoProductPickerSheet extends StatefulWidget {
  const PoProductPickerSheet({super.key, required this.onSelect});

  final ValueChanged<Product> onSelect;

  static void show(BuildContext context, {required ValueChanged<Product> onSelect}) {
    showResponsiveModal(
      context: context,
      title: 'Select Product',
      subtitle: 'Add an item to the purchase order',
      leadingIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.inkTeal, size: 20),
      maxWidth: 560,
      maxHeightFactor: 0.85,
      builder: (_) => PoProductPickerSheet(onSelect: onSelect),
    );
  }

  @override
  State<PoProductPickerSheet> createState() => _PoProductPickerSheetState();
}

class _PoProductPickerSheetState extends State<PoProductPickerSheet> {
  final _inventoryRepo = InventoryRepository();
  String _query = '';
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final res = await _inventoryRepo.fetchProducts();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _products = res.data!;
      }
    });
  }

  List<Product> get _filtered {
    if (_query.isEmpty) return _products;
    final q = _query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search products by name or SKU…',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.slate,
                size: 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No products found.',
                          style: TextStyle(color: AppColors.slate, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: AppColors.paper,
                        title: Text(
                          _filtered[i].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          _filtered[i].sku,
                          style: const TextStyle(fontSize: 11, color: AppColors.slate),
                        ),
                        trailing: Text(
                          'Rs. ${_filtered[i].price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.inkTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          widget.onSelect(_filtered[i]);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
