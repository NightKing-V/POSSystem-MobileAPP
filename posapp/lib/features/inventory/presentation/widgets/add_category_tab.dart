import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/category_repository.dart';

import '../../data/inventory_repository.dart';

/// Tab 2 — Add Category.
/// Standalone widget so add_product_view.dart stays under 250 lines.
class AddCategoryTab extends StatefulWidget {
  const AddCategoryTab({
    super.key,
    required this.onCategoryAdded,
  });

  /// Called after a new category is persisted so Tab 1 can refresh.
  final VoidCallback onCategoryAdded;

  /// Preset color swatches available for category tagging.
  static const List<Color> swatchColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFFD97706), // Amber
    Color(0xFF059669), // Green
    Color(0xFF7C3AED), // Purple
    Color(0xFFEA580C), // Orange
    Color(0xFF0891B2), // Cyan
    Color(0xFFDB2777), // Pink
    Color(0xFF65A30D), // Lime
  ];

  @override
  State<AddCategoryTab> createState() => _AddCategoryTabState();
}

class _AddCategoryTabState extends State<AddCategoryTab> {
  final _inventoryRepo = InventoryRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int _selectedSwatch = 0;
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final res = await _inventoryRepo.fetchCategories();
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() {
        _categories = res.data!
            .map((c) => Category(
                  id: c.id,
                  name: c.name,
                  colorIndex: (c.name.hashCode % AddCategoryTab.swatchColors.length).abs(),
                ))
            .toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final catName = _nameCtrl.text.trim();

    final res = await _inventoryRepo.createCategory(CreateCategoryDto(name: catName));
    if (!mounted) return;

    if (res.isSuccess) {
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      setState(() => _selectedSwatch = 0);
      widget.onCategoryAdded();
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Category created!'),
          ]),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Failed to create category.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    await _inventoryRepo.deleteCategory(id);
    widget.onCategoryAdded();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Form card ────────────────────────────────────────────────
              _Card(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 18)),
                      const SizedBox(height: 20),

                      _Label('Category Name *'),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            hintText: 'e.g. Dairy, Bakery, Electronics'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter category name';
                          }
                          if (_categories.any((c) => c.name.toLowerCase() == v.trim().toLowerCase())) {
                            return 'A category with this name already exists';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _Label('Colour'),
                      _SwatchRow(
                        selected: _selectedSwatch,
                        onSelect: (i) => setState(() => _selectedSwatch = i),
                      ),
                      const SizedBox(height: 28),

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
                            'Create Category',
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
              const SizedBox(height: 20),

              // ── Existing categories ──────────────────────────────────────
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_categories.isNotEmpty)
                _ExistingCategoriesList(
                  categories: _categories,
                  onDelete: _delete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(AddCategoryTab.swatchColors.length, (i) {
        final color = AddCategoryTab.swatchColors[i];
        final isSelected = i == selected;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.ink, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withAlpha(100), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }),
    );
  }
}

class _ExistingCategoriesList extends StatelessWidget {
  const _ExistingCategoriesList({
    required this.categories,
    required this.onDelete,
  });

  final List<Category> categories;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Existing categories',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((c) => _CategoryChip(category: c, onDelete: onDelete))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onDelete});

  final Category category;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final color = category.colorIndex < AddCategoryTab.swatchColors.length
        ? AddCategoryTab.swatchColors[category.colorIndex]
        : AppColors.inkTeal;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(category.name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withAlpha(220))),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => onDelete(category.id),
            child: Icon(Icons.close_rounded, size: 14, color: color.withAlpha(160)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
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
