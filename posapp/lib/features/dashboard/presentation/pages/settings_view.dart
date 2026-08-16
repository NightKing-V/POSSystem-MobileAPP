import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'locations_list_view.dart';
import 'permission_sets_list_view.dart';
import 'employees_list_view.dart';
import 'suppliers_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.businessName});

  final String businessName;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
                      child: Text(
                        businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'B',
                        style: const TextStyle(
                          color: AppColors.inkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Store Admin · Active Session',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: 'General Settings',
                items: [
                  _SettingsItem(
                    icon: Icons.storefront_outlined,
                    title: 'Business Info',
                    subtitle: 'Store location, category and contact info',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Receipt Templates',
                    subtitle: 'Header, footer logos & layouts',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.percent_outlined,
                    title: 'Taxes & Fees',
                    subtitle: 'Configure VAT, service charges, discounts',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: 'Team & Locations',
                items: [
                  _SettingsItem(
                    icon: Icons.storefront_outlined,
                    title: 'Locations',
                    subtitle: 'Manage store branches and addresses',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LocationsListView()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Permission Sets',
                    subtitle: 'Define staff roles and access levels',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PermissionSetsListView()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.badge_outlined,
                    title: 'Employees',
                    subtitle: 'Add staff and assign PINs',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const EmployeesListView()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: 'Inventory',
                items: [
                  _SettingsItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'Suppliers',
                    subtitle: 'Manage vendors and purchase orders',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SuppliersListView()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: 'Hardware & Sync',
                items: [
                  _SettingsItem(
                    icon: Icons.print_outlined,
                    title: 'Thermal Printers',
                    subtitle: 'Bluetooth / LAN printer setups',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.barcode_reader,
                    title: 'Barcode Scanners',
                    subtitle: 'External hardware configurations',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.sync_outlined,
                    title: 'Sync Cache',
                    subtitle: 'Local backup status: All synced',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                ),
                child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Log out?', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text('Are you sure you want to log out and switch business location?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.slate)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Log out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout, color: AppColors.error, size: 20),
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.slate,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                ListTile(
                  onTap: items[i].onTap,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(items[i].icon, color: AppColors.inkTeal, size: 20),
                  ),
                  title: Text(
                    items[i].title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    items[i].subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
                ),
                if (i != items.length - 1)
                  const Divider(color: AppColors.hairline, height: 1, indent: 64),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

