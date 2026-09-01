import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/presentation/pages/categories_list_view.dart';
import '../../../customers/presentation/pages/customers_list_view.dart';
import '../../../staff/presentation/pages/employees_list_view.dart';
import '../../../inventory/presentation/pages/products_list_view.dart';
import '../../../suppliers/presentation/pages/suppliers_list_view.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.businessName,
  });

  final String businessName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.paper,
      elevation: 16,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsListView()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesListView()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Customers',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomersListView()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.badge_outlined,
                  label: 'Employees',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmployeesListView()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Suppliers',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuppliersListView()));
                  },
                ),
                const Divider(color: AppColors.hairline, height: 24, indent: 24, endIndent: 24),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.hairline, height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withValues(alpha: 0.04),
        border: const Border(
          bottom: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.inkTeal.withValues(alpha: 0.12),
            child: const Text(
              'JD', // User initials for John Doe
              style: TextStyle(
                color: AppColors.inkTeal,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
            ),
          const SizedBox(height: 4),
          Text(
            'Store Admin · $businessName',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: _DrawerItem(
        icon: Icons.logout,
        label: 'Log Out',
        textColor: AppColors.error,
        iconColor: AppColors.error,
        onTap: () {},
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor = AppColors.ink,
    this.iconColor = AppColors.slate,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
