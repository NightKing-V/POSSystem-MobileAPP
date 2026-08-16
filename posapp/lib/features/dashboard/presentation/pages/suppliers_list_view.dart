import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';
import '../widgets/supplier_card.dart';
import 'add_edit_supplier_view.dart';
import 'supplier_detail_view.dart';

class SuppliersListView extends StatefulWidget {
  const SuppliersListView({super.key});

  @override
  State<SuppliersListView> createState() => _SuppliersListViewState();
}

class _SuppliersListViewState extends State<SuppliersListView> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<Vendor> get _filtered {
    if (_search.isEmpty) return mockVendors;
    final q = _search.toLowerCase();
    return mockVendors
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.contactPerson.toLowerCase().contains(q) ||
            v.phone.contains(q) ||
            v.email.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendors = _filtered;

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
            Text('Suppliers',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${mockVendors.length} vendors',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
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
                      hintText: 'Search suppliers…',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.slate, size: 20),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: AppColors.slate),
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
                Expanded(
                  child: vendors.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: vendors.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => SupplierCard(
                            vendor: vendors[i],
                            linkedProductCount:
                                vendorLinkedProductCount(vendors[i].id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SupplierDetailView(vendor: vendors[i]),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditSupplierView()),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.local_shipping_outlined,
                size: 48, color: AppColors.slate.withAlpha(80)),
            const SizedBox(height: 16),
            Text('No suppliers yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Add your first vendor to start managing\npurchase orders.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
