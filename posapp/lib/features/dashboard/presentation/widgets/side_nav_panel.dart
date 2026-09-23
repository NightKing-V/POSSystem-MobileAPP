import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../settings/presentation/widgets/settings_dialogs.dart';

/// Navigation Rail / Side Panel for Tablet and Desktop viewports.
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

  Future<void> _handleLogout(BuildContext context) async {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: isExpanded ? 250 : 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(initial),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Top section label
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: Text(
                      'MAIN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                // First 3 options: Home, Bill, Settings
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Bill',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  isExpanded: isExpanded,
                ),

                // Blue Themed Section Separator
                _buildBlueSectionSeparator(),

                // Management module options
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Products',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  label: 'Categories',
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.people_alt_outlined,
                  activeIcon: Icons.people_alt,
                  label: 'Customers',
                  isSelected: selectedIndex == 5,
                  onTap: () => onItemSelected(5),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  label: 'Staff',
                  isSelected: selectedIndex == 6,
                  onTap: () => onItemSelected(6),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  label: 'Suppliers',
                  isSelected: selectedIndex == 7,
                  onTap: () => onItemSelected(7),
                  isExpanded: isExpanded,
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Purchase Orders',
                  isSelected: selectedIndex == 8,
                  onTap: () => onItemSelected(8),
                  isExpanded: isExpanded,
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildBlueSectionSeparator() {
    if (isExpanded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          children: [
            Container(
              width: 3.5,
              height: 13,
              decoration: BoxDecoration(
                color: AppColors.inkTeal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MANAGEMENT',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.inkTeal,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.inkTeal.withValues(alpha: 0.45),
                      AppColors.inkTeal.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          height: 3.5,
          width: 28,
          decoration: BoxDecoration(
            color: AppColors.inkTeal,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.inkTeal.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String initial) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 16 : 12,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: isExpanded
          ? Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.inkTeal, Color(0xFF1F4FB8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.inkTeal.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), // Active status
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Store Admin',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slate,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.inkTeal, Color(0xFF1F4FB8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 12 : 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
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
          const SizedBox(height: 4),
          _NavItem(
            icon: Icons.logout,
            activeIcon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            onTap: () => _handleLogout(context),
            isExpanded: isExpanded,
            iconColor: AppColors.error,
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ??
        (widget.isSelected
            ? AppColors.inkTeal
            : (_isHovered ? AppColors.ink : AppColors.slate));

    final effectiveTextColor = widget.textColor ??
        (widget.isSelected
            ? AppColors.inkTeal
            : (_isHovered ? AppColors.ink : AppColors.ink.withValues(alpha: 0.85)));

    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = AppColors.inkTeal.withValues(alpha: 0.09);
    } else if (_isHovered) {
      backgroundColor = (widget.textColor == AppColors.error)
          ? AppColors.error.withValues(alpha: 0.08)
          : AppColors.inkTeal.withValues(alpha: 0.04);
    } else {
      backgroundColor = Colors.transparent;
    }

    Widget navItemContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isExpanded ? 14 : 10,
          vertical: 10,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: widget.isSelected
              ? Border.all(
                  color: AppColors.inkTeal.withValues(alpha: 0.18),
                  width: 1,
                )
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisAlignment: widget.isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              widget.isSelected ? widget.activeIcon : widget.icon,
              color: effectiveIconColor,
              size: 20,
            ),
            if (widget.isExpanded) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 13.5,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : (_isHovered ? FontWeight.w600 : FontWeight.w500),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!widget.isExpanded) {
      navItemContent = Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 250),
        child: navItemContent,
      );
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: navItemContent,
    );
  }
}
