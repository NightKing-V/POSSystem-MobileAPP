import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../pos/data/bills_repository.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/activity_row.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({
    super.key,
    required this.businessName,
    required this.onQuickActionTap,
    this.orgId,
  });

  final String businessName;
  final ValueChanged<String> onQuickActionTap;
  final String? orgId;

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  final _billsRepo = BillsRepository();
  final _inventoryRepo = InventoryRepository();

  bool _isLoading = false;
  double _todaySales = 0.0;
  int _todayOrders = 0;
  int _productCount = 0;
  List<Map<String, dynamic>> _recentBills = [];

  static const _quickActions = [
    (key: 'dashboard.new_sale', label: 'New Sale', icon: Icons.point_of_sale_outlined),
    (key: 'inventory.title', label: 'Inventory', icon: Icons.inventory_outlined),
    (key: 'suppliers.purchase_orders', label: 'Purchase Orders', icon: Icons.local_shipping_outlined),
    (key: 'dashboard.reports', label: 'Reports', icon: Icons.bar_chart_outlined),
    (key: 'staff.title', label: 'Staff', icon: Icons.people_outline),
    (key: 'settings.title', label: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final billsFuture = _billsRepo.fetchBills(orgId: widget.orgId);
      final productsFuture = _inventoryRepo.fetchProducts();

      final results = await Future.wait([billsFuture, productsFuture]);
      final billsRes = results[0] as ApiResponse<List<Map<String, dynamic>>>;
      final productsRes = results[1] as ApiResponse<dynamic>;

      if (!mounted) return;

      double sales = 0.0;
      int orderCount = 0;
      List<Map<String, dynamic>> billsList = [];

      if (billsRes.isSuccess && billsRes.data != null) {
        billsList = billsRes.data!;
        orderCount = billsList.length;
        for (final b in billsList) {
          final amt = double.tryParse(b['total_amount']?.toString() ??
                  b['amount']?.toString() ??
                  '0') ??
              0.0;
          sales += amt;
        }
      }

      int pCount = 0;
      if (productsRes.isSuccess && productsRes.data != null) {
        if (productsRes.data is List) {
          pCount = (productsRes.data as List).length;
        }
      }

      setState(() {
        _isLoading = false;
        _todaySales = sales;
        _todayOrders = orderCount;
        _productCount = pCount;
        _recentBills = billsList.take(5).toList();
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600;
    final int crossAxisCount = screenWidth > 900 ? 6 : (screenWidth > 600 ? 4 : 3);
    final double childAspectRatio = screenWidth > 600 ? 1.1 : 0.88;

    final stats = [
      (
        label: context.tr('dashboard.today_sales'),
        value: 'Rs. ${_todaySales.toStringAsFixed(_todaySales % 1 == 0 ? 0 : 2)}',
        icon: Icons.payments_outlined
      ),
      (
        label: context.tr('dashboard.total_orders'),
        value: '$_todayOrders',
        icon: Icons.receipt_long_outlined
      ),
      (
        label: context.tr('inventory.products'),
        value: context.tr('dashboard.count_items', args: {'count': _productCount}),
        icon: Icons.inventory_2_outlined
      ),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.inkTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat cards
                isWide
                    ? SizedBox(
                        height: 124,
                        child: Row(
                          children: [
                            for (int i = 0; i < stats.length; i++) ...[
                              Expanded(
                                child: StatCard(
                                  label: stats[i].label,
                                  value: stats[i].value,
                                  icon: stats[i].icon,
                                  width: double.infinity,
                                ),
                              ),
                              if (i != stats.length - 1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 124,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: stats.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final stat = stats[i];
                            return StatCard(
                              label: stat.label,
                              value: stat.value,
                              icon: stat.icon,
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 28),

                Text(
                  context.tr('dashboard.quick_actions'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    for (final action in _quickActions)
                      QuickActionTile(
                        label: context.tr(action.key),
                        icon: action.icon,
                        onTap: () => widget.onQuickActionTap(action.label),
                      ),
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('dashboard.recent_activity'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_recentBills.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.hairline.withValues(alpha: 0.6),
                          width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: AppColors.slate.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('dashboard.no_recent_transactions'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('dashboard.no_recent_transactions_hint'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12, color: AppColors.slate),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.hairline.withValues(alpha: 0.6),
                          width: 1.5),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _recentBills.length; i++) ...[
                          ActivityRow(
                            title: context.tr('dashboard.sale_num', args: {
                              'id': _recentBills[i]['id']?.toString().substring(0, _recentBills[i]['id'].toString().length > 6 ? 6 : null) ?? '${i + 1}'
                            }),
                            subtitle: context.tr('dashboard.sale_completed_detail', args: {
                              'amount': _recentBills[i]['total_amount']?.toString() ?? _recentBills[i]['amount']?.toString() ?? '0'
                            }),
                            time: context.tr('dashboard.recently'),
                          ),
                          if (i != _recentBills.length - 1)
                            Divider(
                                height: 1,
                                color:
                                    AppColors.hairline.withValues(alpha: 0.6)),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
