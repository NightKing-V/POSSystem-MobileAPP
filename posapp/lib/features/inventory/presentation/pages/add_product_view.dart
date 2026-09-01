import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/api/api_helper.dart';
import '../../domain/category_repository.dart';
import '../../data/inventory_repository.dart';
import '../widgets/add_category_tab.dart';

/// Full rewrite rationale: the TabBar/DefaultTabController is a root-level
/// structural change — the entire widget tree must be restructured.
/// Tab 2 is extracted to add_category_tab.dart to keep file size manageable.
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
              _AddProductTab(
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

// =============================================================================
// Tab 1 — Add Product
// =============================================================================

class _AddProductTab extends StatefulWidget {
  const _AddProductTab({
    required this.categories,
    required this.onNewCategoryTap,
  });

  final List<Category> categories;
  final VoidCallback onNewCategoryTap;

  @override
  State<_AddProductTab> createState() => _AddProductTabState();
}

class _AddProductTabState extends State<_AddProductTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String? _selectedCategoryId;

  @override
  void didUpdateWidget(covariant _AddProductTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-select a newly added category.
    if (widget.categories.length > oldWidget.categories.length) {
      final newIds =
          widget.categories.map((c) => c.id).toSet()
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

  void _scanMockBarcode() {
    final mock =
        '8901030${(100000 + (DateTime.now().millisecond * 9)).toString().substring(0, 6)}';
    setState(() => _skuCtrl.text = mock);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock barcode scanned successfully!'),
        duration: Duration(seconds: 1),
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
        subcategoryId: _selectedCategoryId ?? '00000000-0000-0000-0000-000000000000',
        sku: _skuCtrl.text.isNotEmpty ? _skuCtrl.text.trim() : null,
        initialPrice: price > 0 ? price : null,
      );

      final res = await repo.createProduct(dto);

      if (!mounted) return;

      if (res.isSuccess) {
        ApiHelper.showSuccessSnackBar(context, '${_nameCtrl.text} added to inventory!');
        _formKey.currentState!.reset();
        _nameCtrl.clear();
        _skuCtrl.clear();
        _costCtrl.clear();
        _priceCtrl.clear();
        _stockCtrl.clear();
        setState(() => _selectedCategoryId = null);
      } else {
        ApiHelper.showErrorSnackBar(context, res.errorMessage ?? 'Failed to add product.');
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
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.hairline.withAlpha(150), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 18)),
                  const SizedBox(height: 20),

                  // Name
                  _buildLabel('Product Name *'),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: 'e.g. Fresh Milk 1L'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter product name'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // SKU + barcode
                  _buildLabel('SKU / Barcode'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Enter barcode or scan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _scanMockBarcode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.marigold.withAlpha(30),
                            foregroundColor: AppColors.inkTeal,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: AppColors.hairline, width: 1.5),
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
                      _buildLabel('Category *'),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onNewCategoryTap,
                        child: Text(
                          '+ New category',
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
                    hint: const Text('Select a category'),
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: widget.categories
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please select a category'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.hairline, height: 1),
                  const SizedBox(height: 20),

                  Text('Pricing & Stock',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 16)),
                  const SizedBox(height: 16),

                  // Cost / Selling price row
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
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  hintText: '0.00', prefixText: 'Rs. '),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Selling Price *'),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                  hintText: '0.00', prefixText: 'Rs. '),
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

                  // Stock
                  _buildLabel('Initial Stock Level *'),
                  TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '0'),
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
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Add Product to Inventory',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }
}
