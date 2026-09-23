import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../settings/presentation/widgets/settings_dialogs.dart';

/// Navigation Drawer for mobile/narrow viewports.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.businessName,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  final String businessName;
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  void _select(BuildContext context, int index) {
    Navigator.of(context).pop();
    onItemSelected?.call(index);
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.of(context).pop(); // close drawer
    final confirmed = await SettingsDialogs.confirmLogout(context);
    if (!confirmed || !context.mounted) return;

    final authRepo = AuthRepository();
    await authRepo.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = businessName.isNotEmpty
        ? businessName.substring(0, 1).toUpperCase()
        : 'B';

    return Drawer(
      backgroundColor: AppColors.paper,
      elevation: 16,
      child: Column(
        children: [
          _buildHeader(context, initial),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: context.tr('dashboard.home'),
                  isSelected: selectedIndex == 0,
                  onTap: () => _select(context, 0),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: context.tr('dashboard.bill'),
                  isSelected: selectedIndex == 1,
                  onTap: () => _select(context, 1),
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: context.tr('settings.title'),
                  isSelected: selectedIndex == 2,
                  onTap: () => _select(context, 2),
                ),
                const Divider(
                  color: AppColors.hairline,
                  height: 24,
                  indent: 20,
                  endIndent: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Text(
                    'MANAGEMENT',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkTeal,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: context.tr('inventory.products'),
                  isSelected: selectedIndex == 3,
                  onTap: () => _select(context, 3),
                ),
                _DrawerItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  label: context.tr('inventory.categories'),
                  isSelected: selectedIndex == 4,
                  onTap: () => _select(context, 4),
                ),
                _DrawerItem(
                  icon: Icons.people_alt_outlined,
                  activeIcon: Icons.people_alt,
                  label: context.tr('customers.title'),
                  isSelected: selectedIndex == 5,
                  onTap: () => _select(context, 5),
                ),
                _DrawerItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  label: context.tr('staff.employees'),
                  isSelected: selectedIndex == 6,
                  onTap: () => _select(context, 6),
                ),
                _DrawerItem(
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  label: context.tr('suppliers.title'),
                  isSelected: selectedIndex == 7,
                  onTap: () => _select(context, 7),
                ),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: context.tr('suppliers.purchase_orders'),
                  isSelected: selectedIndex == 8,
                  onTap: () => _select(context, 8),
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

  Widget _buildHeader(BuildContext context, String initial) {
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
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.inkTeal,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            businessName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Store Admin · Active Session',
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
        label: context.tr('settings.logout'),
        textColor: AppColors.error,
        iconColor: AppColors.error,
        onTap: () => _handleLogout(context),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ??
        (isSelected ? AppColors.inkTeal : AppColors.slate);
    final effectiveTextColor = textColor ??
        (isSelected ? AppColors.inkTeal : AppColors.ink);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        selected: isSelected,
        selectedTileColor: AppColors.inkTeal.withValues(alpha: 0.08),
        leading: Icon(
          (isSelected && activeIcon != null) ? activeIcon! : icon,
          color: effectiveIconColor,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14.5,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
