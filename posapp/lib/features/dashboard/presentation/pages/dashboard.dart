import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// The main landing screen after a business/branch is selected.
/// UI only — wire the stat values, quick actions, and recent activity
/// list up to your real data sources (Supabase queries / NestJS
/// endpoints) once available.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.businessName});

  final String businessName;

  // Placeholder data — replace with real aggregates for the selected
  // `inventory_location` once wired up.
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

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              businessName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Switch business',
            icon: const Icon(Icons.swap_horiz, color: AppColors.ink),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Align(
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
                          height: 120,
                          child: Row(
                            children: [
                              for (int i = 0; i < _stats.length; i++) ...[
                                Expanded(
                                  child: _StatCard(
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
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _stats.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final stat = _stats[i];
                              return _StatCard(
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
                        _QuickActionTile(
                          label: action.label,
                          icon: action.icon,
                          onTap: () {
                            // TODO: route to the relevant feature page.
                          },
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
                      border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _recentActivity.length; i++) ...[
                          _ActivityRow(
                            title: _recentActivity[i].title,
                            subtitle: _recentActivity[i].subtitle,
                            time: _recentActivity[i].time,
                          ),
                          if (i != _recentActivity.length - 1)
                            Divider(height: 1, color: AppColors.hairline.withValues(alpha: 0.6)),
                        ],
                      ],
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 160,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.inkTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.inkTeal, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.marigold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.inkTeal, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.title, required this.subtitle, required this.time});

  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}