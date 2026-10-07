import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../inventory/domain/models/product.dart';

/// Modal component for searching & selecting a product and entering vendor cost + vendor code.
class LinkProductVendorView extends StatefulWidget {
  const LinkProductVendorView({
    super.key,
    required this.vendorId,
    required this.onLinked,
  });

  final String vendorId;
  final VoidCallback onLinked;

  static Future<void> show(
    BuildContext context, {
    required String vendorId,
    required VoidCallback onLinked,
  }) {
    return showResponsiveModal(
      context: context,
      title: context.tr('suppliers.link_product_title'),
      subtitle: context.tr('suppliers.link_products'),
      leadingIcon: const Icon(Icons.link_rounded, color: AppColors.inkTeal, size: 20),
      maxWidth: 560,
      maxHeightFactor: 0.85,
      builder: (_) => LinkProductVendorView(
        vendorId: vendorId,
        onLinked: onLinked,
      ),
    );
  }

  @override
  State<LinkProductVendorView> createState() => _LinkProductVendorViewState();
}

class _LinkProductVendorViewState extends State<LinkProductVendorView> {
  final _inventoryRepo = InventoryRepository();
  final _formKey = GlobalKey<FormState>();
  String _search = '';
  Product? _selected;
  final _costCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
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
    if (_search.isEmpty) return _products;
    final q = _search.toLowerCase();
    return _products
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
        content: Text(context.tr('common.created_success')),
        backgroundColor: AppColors.inkTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _selected == null
        ? _ProductPicker(
            search: _search,
            filtered: _filtered,
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
          );
  }
}

class _ProductPicker extends StatelessWidget {
  const _ProductPicker({
    required this.search,
    required this.filtered,
    required this.onSearchChanged,
    required this.onSelect,
  });

  final String search;
  final List<Product> filtered;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Product> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: context.tr('common.search'),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.slate, size: 20),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.tr('inventory.no_products'),
                      style: const TextStyle(color: AppColors.slate, fontSize: 13),
                    ),
                  ),
                )
              : ListView.separated(
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
    final formFields = SingleChildScrollView(
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
                  color: AppColors.inkTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.inkTeal.withValues(alpha: 0.25), width: 1.5),
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
            _Label(context.tr('suppliers.purchase_cost')),
            TextFormField(
              controller: costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                  hintText: context.tr('inventory.cost_hint'), prefixText: 'Rs. '),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return context.tr('common.required');
                if (double.tryParse(v) == null) return context.tr('common.error');
                return null;
              },
            ),
            const SizedBox(height: 16),
            _Label(context.tr('suppliers.supplier_sku')),
            TextFormField(
              controller: codeCtrl,
              decoration: InputDecoration(
                  hintText: '${context.tr('inventory.sku_hint')} (${context.tr('common.optional')})'),
            ),
          ],
        ),
      ),
    );

    final actionButton = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.inkTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(context.tr('suppliers.link_products'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: formFields),
        actionButton,
      ],
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
