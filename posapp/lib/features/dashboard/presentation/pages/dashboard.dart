import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customers/presentation/pages/customers_list_view.dart';
import '../../../inventory/presentation/pages/categories_list_view.dart';
import '../../../inventory/presentation/pages/products_list_view.dart';
import '../../../pos/presentation/pages/cart_view.dart';
import '../../../settings/presentation/pages/settings_view.dart';
import '../../../staff/presentation/pages/employees_list_view.dart';
import '../../../suppliers/presentation/pages/purchase_orders_list_view.dart';
import '../../../suppliers/presentation/pages/suppliers_list_view.dart';
import '../widgets/side_nav_panel.dart';
import '../widgets/sidebar.dart';
import './dashboard_home_view.dart';

/// The main landing screen after a business/branch is selected.
/// Featuring navigation between Home, Bill, Settings, and Management Views.
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
        return context.tr('dashboard.bill');
      case 2:
        return context.tr('settings.title');
      case 3:
        return context.tr('inventory.products');
      case 4:
        return context.tr('inventory.categories');
      case 5:
        return context.tr('customers.title');
      case 6:
        return context.tr('staff.title');
      case 7:
        return context.tr('suppliers.title');
      case 8:
        return context.tr('suppliers.purchase_orders');
      default:
        return widget.businessName;
    }
  }

  String _getAppBarSubtitle(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return context.tr('dashboard.title');
      case 1:
        return context.tr('pos.title');
      case 2:
        return context.tr('settings.general');
      case 3:
        return 'Product Catalog & Inventory';
      case 4:
        return 'Inventory Categories';
      case 5:
        return 'Customer Directory & Loyalty';
      case 6:
        return 'Staff & Access Permissions';
      case 7:
        return 'Vendor & Supplier Directory';
      case 8:
        return 'Stock Replenishment Orders';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHomeView(
          businessName: widget.businessName,
          orgId: widget.orgId,
          onQuickActionTap: (actionLabel) {
            if (actionLabel == 'New Sale') {
              setState(() {
                _selectedIndex = 1;
              });
            } else if (actionLabel == 'Settings') {
              setState(() {
                _selectedIndex = 2;
              });
            } else if (actionLabel == 'Inventory') {
              setState(() {
                _selectedIndex = 3;
              });
            } else if (actionLabel == 'Staff') {
              setState(() {
                _selectedIndex = 6;
              });
            } else if (actionLabel == 'Purchase Orders') {
              setState(() {
                _selectedIndex = 8;
              });
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
        return CartView(
          orgId: widget.orgId,
          locationId: widget.locationId,
        );
      case 2:
        return SettingsView(
          businessName: widget.businessName,
          orgId: widget.orgId,
        );
      case 3:
        return const ProductsListView(isEmbedded: true);
      case 4:
        return const CategoriesListView(isEmbedded: true);
      case 5:
        return CustomersListView(orgId: widget.orgId, isEmbedded: true);
      case 6:
        return EmployeesListView(orgId: widget.orgId, isEmbedded: true);
      case 7:
        return SuppliersListView(orgId: widget.orgId, isEmbedded: true);
      case 8:
        return PurchaseOrdersListView(orgId: widget.orgId, isEmbedded: true);
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
      appBar: (isWide && _selectedIndex >= 3)
          ? null
          : AppBar(
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
          : Sidebar(
              businessName: widget.businessName,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
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
                currentIndex: _selectedIndex <= 2 ? _selectedIndex : 0,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.inkTeal,
                unselectedItemColor: AppColors.slate,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard),
                    label: context.tr('dashboard.home'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.receipt_long_outlined),
                    activeIcon: const Icon(Icons.receipt_long),
                    label: context.tr('dashboard.bill'),
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