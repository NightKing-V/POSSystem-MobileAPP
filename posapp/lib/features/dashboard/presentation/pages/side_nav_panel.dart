import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SideNavPanel extends StatelessWidget {
  const SideNavPanel({
    super.key,
    required this.businessName,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onSwitchBusiness,
    required this.isExpanded,
  });

  final String businessName;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onSwitchBusiness;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isExpanded ? 240 : 72,
      child: Material(
        color: AppColors.paper,
        elevation: 4,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Home',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                    isExpanded: isExpanded,
                  ),
                  _NavItem(
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    label: 'Add Product',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                    isExpanded: isExpanded,
                  ),
                  _NavItem(
                    icon: Icons.shopping_cart_outlined,
                    activeIcon: Icons.shopping_cart,
                    label: 'Cart',
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                    isExpanded: isExpanded,
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                    isExpanded: isExpanded,
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 16 : 8,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),
      child: isExpanded
          ? Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.inkTeal.withValues(alpha: 0.12),
                  child: const Text('JD', style: TextStyle(color: AppColors.inkTeal, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(businessName, style: const TextStyle(fontSize: 12, color: AppColors.slate), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            )
          : CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.inkTeal.withValues(alpha: 0.12),
              child: const Text('JD', style: TextStyle(color: AppColors.inkTeal, fontSize: 12)),
            ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 12,
      ),
      child: Column(
        children: [
          _NavItem(
            icon: Icons.swap_horiz,
            activeIcon: Icons.swap_horiz,
            label: 'Switch Business',
            isSelected: false,
            onTap: onSwitchBusiness,
            isExpanded: isExpanded,
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.logout,
            activeIcon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            onTap: () {},
            isExpanded: isExpanded,
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isExpanded,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? (isSelected ? AppColors.inkTeal : AppColors.slate);
    final effectiveTextColor = textColor ?? (isSelected ? AppColors.inkTeal : AppColors.ink);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.inkTeal.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: effectiveIconColor,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
