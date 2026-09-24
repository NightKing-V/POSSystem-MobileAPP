import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
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

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

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

  List<CustomerProps> get _processedCustomers {
    var list = _customers;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((c) =>
              c.fullName.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              (c.email != null && c.email!.toLowerCase().contains(q)))
          .toList();
    }

    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            break;
          case 1:
            comp = a.phone.compareTo(b.phone);
            break;
          case 2:
            comp = (a.email ?? '').toLowerCase().compareTo((b.email ?? '').toLowerCase());
            break;
          case 3:
            comp = a.loyaltyPoints.compareTo(b.loyaltyPoints);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
  }

  void _openAddCustomer([CustomerProps? customer]) async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: customer != null ? 'Edit Customer' : context.tr('customers.add_customer'),
      subtitle: customer != null
          ? customer.fullName
          : 'Register a new customer for loyalty & billing',
      leadingIcon: const Icon(Icons.person_add_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 620,
      builder: (_) => AddCustomerView(orgId: widget.orgId, isModal: true),
    );
    if (res == true) {
      _loadCustomers();
    }
  }

  void _handleDelete(CustomerProps customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to remove "${customer.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _customers.removeWhere((c) => c.id == customer.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${customer.fullName}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _processedCustomers;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('customers.title'),
          subtitle: 'Customer Directory & Loyalty Management',
          itemCountText:
              '${list.length} ${list.length == 1 ? 'customer' : 'customers'}',
          searchCtrl: _searchCtrl,
          searchHint: context.tr('customers.search_customers'),
          onSearchChanged: (v) => setState(() => _search = v),
          actionLabel: context.tr('customers.add_customer'),
          actionIcon: Icons.add,
          onActionTap: () => _openAddCustomer(),
        ),
        Expanded(
          child: ManagementGridTable<CustomerProps>(
            items: list,
            isLoading: _isLoading,
            emptyTitle: context.tr('customers.no_customers'),
            emptySubtitle: context.tr('customers.no_customers_hint'),
            emptyIcon: Icons.people_alt_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onEdit: (c) => _openAddCustomer(c),
            onDelete: (c) => _handleDelete(c),
            columns: [
              ManagementTableColumn<CustomerProps>(
                label: 'Customer Name',
                flex: 3,
                isSortable: true,
                cellBuilder: (c, _) => Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor:
                          AppColors.inkTeal.withValues(alpha: 0.1),
                      child: Text(
                        c.fullName.isNotEmpty
                            ? c.fullName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: AppColors.inkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<CustomerProps>(
                label: 'Phone Number',
                flex: 2,
                isSortable: true,
                cellBuilder: (c, _) => Text(
                  c.phone.isNotEmpty ? c.phone : '—',
                  style: const TextStyle(fontSize: 13, color: AppColors.ink),
                ),
              ),
              ManagementTableColumn<CustomerProps>(
                label: 'Email Address',
                flex: 2,
                isSortable: true,
                cellBuilder: (c, _) => Text(
                  c.email ?? '—',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.slate),
                ),
              ),
              ManagementTableColumn<CustomerProps>(
                label: 'Loyalty Points',
                flex: 2,
                isSortable: true,
                alignment: Alignment.centerRight,
                cellBuilder: (c, _) => c.isLoyaltyMember
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.marigold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${c.loyaltyPoints} ${context.tr('common.pts')}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      )
                    : const Align(
                        alignment: Alignment.centerRight,
                        child: Text('—', style: TextStyle(color: AppColors.slate)),
                      ),
              ),
            ],
            cardBuilder: (ctx, c, _) => Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.hairline.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              child: InkWell(
                onTap: () => _openAddCustomer(c),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppColors.inkTeal.withValues(alpha: 0.1),
                        child: Text(
                          c.fullName.isNotEmpty
                              ? c.fullName[0].toUpperCase()
                              : 'C',
                          style: const TextStyle(
                            color: AppColors.inkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.phone.isNotEmpty
                                  ? c.phone
                                  : (c.email ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (c.isLoyaltyMember) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.marigold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${c.loyaltyPoints} ${context.tr('common.pts')}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: context.tr('customers.add_customer'),
      onTap: () => _openAddCustomer(),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: fab,
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
            Text(context.tr('customers.title'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text(
                context.tr('customers.count_customers',
                    args: {'count': list.length}),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}
