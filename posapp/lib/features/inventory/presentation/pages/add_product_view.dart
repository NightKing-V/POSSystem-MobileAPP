import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../data/inventory_repository.dart';
import './add_category_view.dart';

/// Lightweight standalone form for creating a new product.
class AddProductView extends StatefulWidget {
  const AddProductView({
    super.key,
    this.isModal = true,
  });

  final bool isModal;

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _inventoryRepo = InventoryRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  List<CategoryProps> _categories = [];
  String? _selectedCategoryId;
  bool _isLoadingCats = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
      }
    });
  }

  void _generateBarcode() {
    final code =
        '8901030${(100000 + (DateTime.now().millisecond * 9)).toString().substring(0, 6)}';
    setState(() => _skuCtrl.text = code);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode generated successfully!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openNewCategoryModal() async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: context.tr('inventory.add_category'),
      subtitle: 'Create a new category tag for products',
      leadingIcon: const Icon(Icons.category_outlined, color: AppColors.inkTeal, size: 20),
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final price = double.tryParse(_priceCtrl.text) ?? 0.0;
      final dto = CreateProductDto(
        name: _nameCtrl.text.trim(),
        subcategoryId:
            _selectedCategoryId ?? '00000000-0000-0000-0000-000000000000',
        sku: _skuCtrl.text.isNotEmpty ? _skuCtrl.text.trim() : null,
        initialPrice: price > 0 ? price : null,
      );

      final res = await _inventoryRepo.createProduct(dto);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (res.isSuccess) {
        ApiHelper.showSuccessSnackBar(
            context, '${_nameCtrl.text} added to inventory!');
        Navigator.of(context).pop(true);
      } else {
        ApiHelper.showErrorSnackBar(
            context, res.errorMessage ?? 'Failed to add product.');
      }
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
            _buildSectionHeader('General Information'),
            const SizedBox(height: 14),

            _buildLabel('Product Name *'),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Fresh Milk 1L, Cinnamon Tea 100g',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter product name'
                  : null,
            ),
            const SizedBox(height: 16),

            // SKU + Barcode Row
            _buildLabel('SKU / Barcode'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skuCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter or scan barcode',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _generateBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Generate', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.inkTeal,
                      side: const BorderSide(color: AppColors.hairline, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                _buildLabel('Category *'),
                TextButton.icon(
                  onPressed: _openNewCategoryModal,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.inkTeal),
                  label: const Text(
                    'New Category',
                    style: TextStyle(
                      color: AppColors.inkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              hint: Text(_isLoadingCats ? 'Loading categories...' : 'Select a category'),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please select a category'
                  : null,
            ),
            const SizedBox(height: 24),

            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 20),

            // Section 2: Pricing & Stock
            _buildSectionHeader('Pricing & Stock'),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Cost Price (Rs.)'),
                      TextFormField(
                        controller: _costCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: 'Rs. ',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Selling Price *'),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: 'Rs. ',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Invalid number';
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

            _buildLabel('Initial Stock Level *'),
            TextFormField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 50'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter initial stock';
                }
                if (int.tryParse(v) == null) {
                  return 'Invalid integer';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate,
                      side: const BorderSide(color: AppColors.hairline, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 52),
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
                      minimumSize: const Size(0, 52),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
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
          ],
        ),
      ),
    );

    if (widget.isModal) {
      return formBody;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          context.tr('inventory.add_product'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: formBody),
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
