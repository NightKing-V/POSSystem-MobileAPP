import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'dashboard_home_view.dart';
import 'add_product_view.dart';
import 'cart_view.dart';
import 'settings_view.dart';
import 'employees_list_view.dart';
import 'purchase_orders_list_view.dart';

/// The main landing screen after a business/branch is selected.
/// Featuring a bottom navigation bar to switch between Home, Add Product, Cart, and Settings.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.businessName});

  final String businessName;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return widget.businessName;
      case 1:
        return 'Add Product';
      case 2:
        return 'Active Cart';
      case 3:
        return 'Settings';
      default:
        return widget.businessName;
    }
  }

  String _getAppBarSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Create inventory items';
      case 2:
        return 'Cashier billing';
      case 3:
        return 'App configuration';
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
                  content: Text('Quick Action: "$actionLabel" tapped (Feature under construction).'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      case 1:
        return const AddProductView();
      case 2:
        // CartView is fully self-contained — owns its own cart state.
        return const CartView();
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
              _getAppBarTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
            Text(
              _getAppBarSubtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: _buildAppBarActions(),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.hairline.withOpacity(0.6),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add Product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}