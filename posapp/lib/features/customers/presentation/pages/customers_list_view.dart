import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import './add_customer_view.dart';

import '../../data/customers_repository.dart';

class CustomersListView extends StatefulWidget {
  const CustomersListView({super.key, this.orgId, this.isEmbedded = false});

  final String? orgId;
  final bool isEmbedded;

  @override
  State<CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<CustomersListView> {
  final _customersRepo = CustomersRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<CustomerProps> _customers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final response = await _customersRepo.fetchCustomers(orgId: widget.orgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _customers = response.data!;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerProps> get _filteredCustomers {
    if (_search.isEmpty) return _customers;
    final q = _search.toLowerCase();
    return _customers.where((c) =>
        c.fullName.toLowerCase().contains(q) ||
        c.phone.toLowerCase().contains(q) ||
        (c.email != null && c.email!.toLowerCase().contains(q))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCustomers;

    final body = Align(
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
                  hintText: context.tr('customers.search_customers'),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.slate),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: list.length,
                          itemBuilder: (ctx, i) {
                            final c = list[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.hairline.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
                                  child: Text(
                                    c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : 'C',
                                    style: const TextStyle(
                                      color: AppColors.inkTeal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  c.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  c.phone.isNotEmpty ? c.phone : (c.email ?? ''),
                                  style: const TextStyle(color: AppColors.slate, fontSize: 13),
                                ),
                                trailing: c.isLoyaltyMember
                                    ? Chip(
                                        label: Text('${c.loyaltyPoints} ${context.tr('common.pts')}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        backgroundColor: AppColors.marigold.withValues(alpha: 0.2),
                                        padding: EdgeInsets.zero,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final res = await Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => AddCustomerView(orgId: widget.orgId),
              ),
            );
            if (res == true) {
              _loadCustomers();
            }
          },
          backgroundColor: AppColors.inkTeal,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(context.tr('customers.add_customer'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

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
            Text(context.tr('customers.title'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
            Text(context.tr('customers.count_customers', args: {'count': list.length}),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => AddCustomerView(orgId: widget.orgId),
            ),
          );
          if (res == true) {
            _loadCustomers();
          }
        },
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.tr('customers.add_customer'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.people_alt_outlined, size: 48, color: AppColors.slate.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(context.tr('customers.no_customers'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text(context.tr('customers.no_customers_hint'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
