import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/inventory_repository.dart';
import '../../domain/category_repository.dart';

/// Tab 1 presentation form for creating a new product.
class AddProductTab extends StatefulWidget {
  const AddProductTab({
    super.key,
    required this.categories,
    required this.onNewCategoryTap,
  });

  final List<Category> categories;
  final VoidCallback onNewCategoryTap;

  @override
  State<AddProductTab> createState() => _AddProductTabState();
}

class _AddProductTabState extends State<AddProductTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String? _selectedCategoryId;

  @override
  void didUpdateWidget(covariant AddProductTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-select newly added category.
    if (widget.categories.length > oldWidget.categories.length) {
      final newIds = widget.categories
          .map((c) => c.id)
          .toSet()
          .difference(oldWidget.categories.map((c) => c.id).toSet());
      if (newIds.isNotEmpty) {
        setState(() => _selectedCategoryId = newIds.first);
      }
    }
    // Clear selection if selected category was deleted.
    if (_selectedCategoryId != null &&
        !widget.categories.any((c) => c.id == _selectedCategoryId)) {
      setState(() => _selectedCategoryId = null);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _costCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _generateBarcode() {
    final code =
        '8901030${(100000 + (DateTime.now().millisecond * 9)).toString().substring(0, 6)}';
    setState(() => _skuCtrl.text = code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('common.success')),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final repo = InventoryRepository();
      final price = double.tryParse(_priceCtrl.text) ?? 0.0;
      final dto = CreateProductDto(
        name: _nameCtrl.text.trim(),
        subcategoryId:
            _selectedCategoryId ?? '00000000-0000-0000-0000-000000000000',
        sku: _skuCtrl.text.isNotEmpty ? _skuCtrl.text.trim() : null,
        initialPrice: price > 0 ? price : null,
      );

      final res = await repo.createProduct(dto);

      if (!mounted) return;

      if (res.isSuccess) {
        ApiHelper.showSuccessSnackBar(
            context, context.tr('common.created_success'));
        Navigator.of(context).pop(true);
      } else {
        ApiHelper.showErrorSnackBar(
            context, res.errorMessage ?? context.tr('common.error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.hairline.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('inventory.product_details'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  _buildLabel(context.tr('inventory.product_name')),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: context.tr('inventory.product_name_hint'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.tr('inventory.product_name_required')
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // SKU + barcode
                  _buildLabel(context.tr('inventory.barcode')),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuCtrl,
                          decoration: InputDecoration(
                            hintText: context.tr('inventory.barcode_hint'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _generateBarcode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.marigold.withValues(alpha: 0.12),
                            foregroundColor: AppColors.inkTeal,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: AppColors.hairline,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: const Icon(Icons.qr_code_scanner),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown + new category link
                  Row(
                    children: [
                      _buildLabel(context.tr('inventory.category')),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onNewCategoryTap,
                        child: Text(
                          '+ ${context.tr('inventory.add_category')}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.inkTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    hint: Text(context.tr('inventory.select_category')),
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: widget.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => (v == null || v.isEmpty)
                        ? context.tr('inventory.select_category')
                        : null,
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.hairline, height: 1),
                  const SizedBox(height: 20),

                  Text(
                    context.tr('inventory.title'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Cost / Selling price row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.tr('inventory.cost')),
                            TextFormField(
                              controller: _costCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: context.tr('inventory.cost_hint'),
                                prefixText: 'Rs. ',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context.tr('inventory.price')),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: context.tr('inventory.price_hint'),
                                prefixText: 'Rs. ',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return context.tr('inventory.price_required');
                                }
                                if (double.tryParse(v) == null) {
                                  return context.tr('common.error');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  _buildLabel(context.tr('inventory.stock_qty')),
                  TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: context.tr('inventory.stock_qty_hint')),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return context.tr('common.required');
                      }
                      if (int.tryParse(v) == null) {
                        return context.tr('common.error');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.inkTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        context.tr('inventory.add_product'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
      ),
    );
  }
}
