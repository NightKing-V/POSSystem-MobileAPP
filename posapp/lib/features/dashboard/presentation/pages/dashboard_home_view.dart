import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/activity_row.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({
    super.key,
    required this.businessName,
    required this.onQuickActionTap,
  });

  final String businessName;
  final ValueChanged<String> onQuickActionTap;

  static const _stats = [
    (label: "Today's Sales", value: 'Rs. 42,500', icon: Icons.payments_outlined),
    (label: 'Orders', value: '18', icon: Icons.receipt_long_outlined),
    (label: 'Low Stock', value: '5 items', icon: Icons.inventory_2_outlined),
  ];

  static const _quickActions = [
    (label: 'New Sale', icon: Icons.point_of_sale_outlined),
    (label: 'Inventory', icon: Icons.inventory_outlined),
    (label: 'Purchase Orders', icon: Icons.local_shipping_outlined),
    (label: 'Reports', icon: Icons.bar_chart_outlined),
    (label: 'Staff', icon: Icons.people_outline),
    (label: 'Settings', icon: Icons.settings_outlined),
  ];

  static const _recentActivity = [
    (title: 'Sale #1042', subtitle: '3 items · Rs. 3,200', time: '2m ago'),
    (title: 'Sale #1041', subtitle: '1 item · Rs. 950', time: '18m ago'),
    (title: 'Stock received', subtitle: 'Purchase order #88', time: '1h ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600;
    final int crossAxisCount = screenWidth > 900 ? 6 : (screenWidth > 600 ? 4 : 3);
    final double childAspectRatio = screenWidth > 600 ? 1.1 : 0.88;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat cards
              isWide
                  ? SizedBox(
                      height: 108,
                      child: Row(
                        children: [
                          for (int i = 0; i < _stats.length; i++) ...[
                            Expanded(
                              child: StatCard(
                                label: _stats[i].label,
                                value: _stats[i].value,
                                icon: _stats[i].icon,
                                width: double.infinity,
                              ),
                            ),
                            if (i != _stats.length - 1) const SizedBox(width: 12),
                          ],
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _stats.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final stat = _stats[i];
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
                'Quick actions',
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
                      label: action.label,
                      icon: action.icon,
                      onTap: () => onQuickActionTap(action.label),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withOpacity(0.6), width: 1.5),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _recentActivity.length; i++) ...[
                      ActivityRow(
                        title: _recentActivity[i].title,
                        subtitle: _recentActivity[i].subtitle,
                        time: _recentActivity[i].time,
                      ),
                      if (i != _recentActivity.length - 1)
                        Divider(height: 1, color: AppColors.hairline.withOpacity(0.6)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
