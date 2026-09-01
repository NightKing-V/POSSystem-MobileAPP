import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import './dashboard_home_view.dart';
import '../../../inventory/presentation/pages/add_product_view.dart';
import '../../../pos/presentation/pages/cart_view.dart';
import '../../../settings/presentation/pages/settings_view.dart';
import '../../../staff/presentation/pages/employees_list_view.dart';
import '../../../suppliers/presentation/pages/purchase_orders_list_view.dart';
import './side_nav_panel.dart';
import './sidebar.dart';

/// The main landing screen after a business/branch is selected.
/// Featuring a bottom navigation bar to switch between Home, Add Product, Cart, and Settings.
class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.businessName,
    this.orgId,
    this.locationId,
  });

  final String businessName;
  final String? orgId;
  final String? locationId;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  String _getAppBarTitle(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return widget.businessName;
      case 1:
        return context.tr('inventory.add_product');
      case 2:
        return context.tr('pos.cart');
      case 3:
        return context.tr('settings.title');
      default:
        return widget.businessName;
    }
  }

  String _getAppBarSubtitle(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return context.tr('dashboard.title');
      case 1:
        return context.tr('inventory.title');
      case 2:
        return context.tr('pos.title');
      case 3:
        return context.tr('settings.general');
      default:
        return '';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHomeView(
          businessName: widget.businessName,
          onQuickActionTap: (actionLabel) {
            if (actionLabel == 'New Sale') {
              setState(() {
                _selectedIndex = 2;
              });
            } else if (actionLabel == 'Settings') {
              setState(() {
                _selectedIndex = 3;
              });
            } else if (actionLabel == 'Inventory') {
              setState(() {
                _selectedIndex = 1;
              });
            } else if (actionLabel == 'Staff') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmployeesListView(),
                ),
              );
            } else if (actionLabel == 'Purchase Orders') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PurchaseOrdersListView(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Quick Action: "$actionLabel" tapped.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      case 1:
        return const AddProductView();
      case 2:
        // CartView connected to real Org & Location
        return CartView(
          orgId: widget.orgId,
          locationId: widget.locationId,
        );
      case 3:
        return SettingsView(businessName: widget.businessName);
      default:
        return Container();
    }
  }

  List<Widget>? _buildAppBarActions() {
    if (_selectedIndex == 0) {
      return [
        IconButton(
          tooltip: 'Switch business',
          icon: const Icon(Icons.swap_horiz, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    final scaffold = Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        automaticallyImplyLeading: !isWide,
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getAppBarTitle(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
            Text(
              _getAppBarSubtitle(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: isWide ? null : _buildAppBarActions(),
      ),
      drawer: isWide
          ? null
          : Sidebar(businessName: widget.businessName),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.hairline.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.inkTeal,
                unselectedItemColor: AppColors.slate,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: context.tr('dashboard.title'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.add_circle_outline),
                    activeIcon: const Icon(Icons.add_circle),
                    label: context.tr('inventory.add_product'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    activeIcon: const Icon(Icons.shopping_cart),
                    label: context.tr('pos.cart'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: const Icon(Icons.settings),
                    label: context.tr('settings.title'),
                  ),
                ],
              ),
            ),
    );

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: Row(
          children: [
            SideNavPanel(
              businessName: widget.businessName,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              onSwitchBusiness: () => Navigator.of(context).pop(),
              isExpanded: isDesktop,
            ),
            Expanded(child: scaffold),
          ],
        ),
      );
    }

    return scaffold;
  }
}