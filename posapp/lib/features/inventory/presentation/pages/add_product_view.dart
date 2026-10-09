import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/form_field_label.dart';
import '../../data/inventory_repository.dart';
import '../../domain/models/product.dart';
import '../validators/inventory_validators.dart';
import './add_category_view.dart';

/// Lightweight standalone form for creating or editing a product.
class AddProductView extends StatefulWidget {
  const AddProductView({super.key, this.product, this.isModal = true});

  final Product? product;
  final bool isModal;

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _inventoryRepo = InventoryRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  final _costCtrl = TextEditingController();
  late final TextEditingController _priceCtrl;
  final _stockCtrl = TextEditingController();

  List<CategoryProps> _categories = [];
  String? _selectedCategoryId;
  bool _isLoadingCats = false;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _skuCtrl = TextEditingController(text: widget.product?.sku ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product != null && widget.product!.price > 0
          ? widget.product!.price.toStringAsFixed(2)
          : '',
    );
    _loadCategories();
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

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCats = true);
    final res = await _inventoryRepo.fetchCategories();
    if (!mounted) return;
    setState(() {
      _isLoadingCats = false;
      if (res.isSuccess && res.data != null) {
        _categories = res.data!;
        // Match existing category by name if editing
        if (_isEditing && widget.product!.category.isNotEmpty) {
          final matched = _categories.where(
            (c) =>
                c.name.toLowerCase() == widget.product!.category.toLowerCase(),
          );
          if (matched.isNotEmpty) {
            _selectedCategoryId = matched.first.id;
          }
        }
      }
    });
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

  Future<void> _openNewCategoryModal() async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: context.tr('inventory.add_category'),
      subtitle: context.tr('inventory.no_categories_hint'),
      leadingIcon: const Icon(
        Icons.category_outlined,
        color: AppColors.inkTeal,
        size: 20,
      ),
      maxWidth: 480,
      builder: (_) => const AddCategoryView(isModal: true),
    );

    if (res == true) {
      final oldIds = _categories.map((c) => c.id).toSet();
      await _loadCategories();
      final newCats = _categories.where((c) => !oldIds.contains(c.id)).toList();
      if (newCats.isNotEmpty && mounted) {
        setState(() => _selectedCategoryId = newCats.first.id);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;

    final ApiResponse<Map<String, dynamic>> res;

    if (_isEditing) {
      final updateData = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        if (_skuCtrl.text.isNotEmpty) 'SKU': _skuCtrl.text.trim(),
        if (price > 0) 'initialPrice': price,
        if (_selectedCategoryId != null) 'subcategoryid': _selectedCategoryId,
      };
      res = await _inventoryRepo.updateProduct(widget.product!.id, updateData);
    } else {
      final dto = CreateProductDto(
        name: _nameCtrl.text.trim(),
        subcategoryId:
            _selectedCategoryId ?? '00000000-0000-0000-0000-000000000000',
        sku: _skuCtrl.text.isNotEmpty ? _skuCtrl.text.trim() : null,
        initialPrice: price > 0 ? price : null,
      );
      res = await _inventoryRepo.createProduct(dto);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing
            ? context.tr('common.updated_success')
            : context.tr('common.created_success'),
      );
      Navigator.of(context).pop(true);
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? context.tr('common.error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Basic Info
            _buildSectionHeader(context.tr('settings.general')),
            const SizedBox(height: 14),

            AppTextFormField(
              label: context.tr('inventory.product_name'),
              isRequired: true,
              controller: _nameCtrl,
              hintText: context.tr('inventory.product_name_hint'),
              validator: InventoryValidators.productName.validate,
            ),
            const SizedBox(height: 16),

            // SKU + Barcode Row
            FormFieldLabel(label: context.tr('inventory.barcode')),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextFormField(
                    controller: _skuCtrl,
                    validator: InventoryValidators.sku.validate,
                    hintText: context.tr('inventory.barcode_hint'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _generateBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text(
                      context.tr('common.apply'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.inkTeal,
                      side: const BorderSide(
                        color: AppColors.hairline,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FormFieldLabel(
                  label: context.tr('inventory.category'),
                  isRequired: true,
                ),
                TextButton.icon(
                  onPressed: _openNewCategoryModal,
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.inkTeal,
                  ),
                  label: Text(
                    context.tr('inventory.add_category'),
                    style: const TextStyle(
                      color: AppColors.inkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              hint: Text(
                _isLoadingCats
                    ? context.tr('common.loading')
                    : context.tr('inventory.select_category'),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: InventoryValidators.category.validate,
            ),
            const SizedBox(height: 24),

            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 20),

            // Section 2: Pricing & Stock
            _buildSectionHeader(context.tr('inventory.product_details')),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextFormField(
                    label: context.tr('inventory.cost'),
                    isRequired: false,
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('inventory.cost_hint'),
                      prefixText: 'Rs. ',
                    ),
                    validator: InventoryValidators.costPrice.validate,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppTextFormField(
                    label: context.tr('inventory.price'),
                    isRequired: true,
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('inventory.price_hint'),
                      prefixText: 'Rs. ',
                    ),
                    validator: InventoryValidators.sellingPrice.validate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextFormField(
              label: context.tr('inventory.stock_qty'),
              isRequired: true,
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              hintText: context.tr('inventory.stock_qty_hint'),
              validator: InventoryValidators.stockQuantity.validate,
            ),
          ],
        ),
      ),
    );

    final actionButtons = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate,
                side: const BorderSide(color: AppColors.hairline, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: Text(context.tr('common.cancel')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.tr('inventory.add_product'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: formBody),
        actionButtons,
      ],
    );

    if (widget.isModal) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          context.tr('inventory.add_product'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.ink,
      ),
    );
  }
}
