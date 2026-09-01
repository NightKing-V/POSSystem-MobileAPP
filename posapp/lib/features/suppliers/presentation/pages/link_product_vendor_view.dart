import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/domain/models/product.dart';

/// Bottom sheet: search & select a product, enter vendor cost + vendor code.
class LinkProductVendorView extends StatefulWidget {
  const LinkProductVendorView({
    super.key,
    required this.vendorId,
    required this.onLinked,
  });

  final String vendorId;
  final VoidCallback onLinked;

  @override
  State<LinkProductVendorView> createState() => _LinkProductVendorViewState();
}

class _LinkProductVendorViewState extends State<LinkProductVendorView> {
  final _formKey = GlobalKey<FormState>();
  String _search = '';
  Product? _selected;
  final _costCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  List<Product> get _filtered {
    if (_search.isEmpty) return Product.mockProducts;
    final q = _search.toLowerCase();
    return Product.mockProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _link() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    widget.onLinked();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selected!.name} linked to supplier.'),
        backgroundColor: AppColors.inkTeal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text('Link a Product',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.slate),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),
            Expanded(
              child: _selected == null
                  ? _ProductPicker(
                      search: _search,
                      filtered: _filtered,
                      scrollController: controller,
                      onSearchChanged: (v) => setState(() => _search = v),
                      onSelect: (p) => setState(() => _selected = p),
                    )
                  : _LinkForm(
                      formKey: _formKey,
                      product: _selected!,
                      costCtrl: _costCtrl,
                      codeCtrl: _codeCtrl,
                      onBack: () => setState(() => _selected = null),
                      onLink: _link,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPicker extends StatelessWidget {
  const _ProductPicker({
    required this.search,
    required this.filtered,
    required this.scrollController,
    required this.onSearchChanged,
    required this.onSelect,
  });

  final String search;
  final List<Product> filtered;
  final ScrollController scrollController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Product> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search products by name or SKU…',
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.slate, size: 20),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => ListTile(
              onTap: () => onSelect(filtered[i]),
              tileColor: AppColors.paper,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(filtered[i].name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(filtered[i].sku,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.slate)),
              trailing: Text('Rs. ${filtered[i].price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.inkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkForm extends StatelessWidget {
  const _LinkForm({
    required this.formKey,
    required this.product,
    required this.costCtrl,
    required this.codeCtrl,
    required this.onBack,
    required this.onLink,
  });

  final GlobalKey<FormState> formKey;
  final Product product;
  final TextEditingController costCtrl;
  final TextEditingController codeCtrl;
  final VoidCallback onBack;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected product chip
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inkTeal.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.inkTeal.withAlpha(50), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: AppColors.inkTeal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.inkTeal)),
                    ),
                    const Icon(Icons.swap_horiz_rounded,
                        color: AppColors.slate, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _Label('Vendor Unit Cost (Rs.) *'),
            TextFormField(
              controller: costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'))
              ],
              decoration: const InputDecoration(
                  hintText: '0.00', prefixText: 'Rs. '),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter vendor cost';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const _Label("Vendor's Product Code"),
            TextFormField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                  hintText: 'e.g. LF-MILK-1L (optional)'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inkTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Link Product',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }
}
