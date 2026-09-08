import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/domain/models/product.dart';

/// Modal bottom sheet for searching and selecting products for a purchase order.
class PoProductPickerSheet extends StatefulWidget {
  const PoProductPickerSheet({super.key, required this.onSelect});

  final ValueChanged<Product> onSelect;

  static void show(BuildContext context, {required ValueChanged<Product> onSelect}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PoProductPickerSheet(onSelect: onSelect),
    );
  }

  @override
  State<PoProductPickerSheet> createState() => _PoProductPickerSheetState();
}

class _PoProductPickerSheetState extends State<PoProductPickerSheet> {
  String _query = '';

  List<Product> get _filtered {
    if (_query.isEmpty) return Product.mockProducts;
    return Product.mockProducts
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search products…',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.slate,
                    size: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
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
        ),
      ),
    );
  }
}
