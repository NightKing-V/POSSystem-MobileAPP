import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/auth_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cashier Register Terminal Mock State
  final List<Map<String, dynamic>> _cart = [];
  double _totalAmount = 0.0;
  bool _isProcessingCheckout = false;

  final List<Map<String, dynamic>> _catalog = [
    {'id': 'p1', 'name': 'Double Espresso', 'price': 3.50, 'icon': Icons.coffee},
    {'id': 'p2', 'name': 'Café Latte', 'price': 4.50, 'icon': Icons.local_cafe},
    {'id': 'p3', 'name': 'Butter Croissant', 'price': 2.75, 'icon': Icons.bakery_dining},
    {'id': 'p4', 'name': 'Blueberry Muffin', 'price': 3.25, 'icon': Icons.cake},
    {'id': 'p5', 'name': 'Iced Matcha Tea', 'price': 4.95, 'icon': Icons.emoji_food_beverage},
    {'id': 'p6', 'name': 'Cold Brew Bottle', 'price': 4.25, 'icon': Icons.wine_bar},
  ];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['product']['id'] == product['id']);
      if (index >= 0) {
        _cart[index]['quantity']++;
      } else {
        _cart.add({'product': product, 'quantity': 1});
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index]['quantity'] > 1) {
        _cart[index]['quantity']--;
      } else {
        _cart.removeAt(index);
      }
      _calculateTotal();
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _totalAmount = 0.0;
    });
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in _cart) {
      total += (item['product']['price'] as double) * (item['quantity'] as int);
    }
    _totalAmount = total;
  }

  Future<void> _processCheckout() async {
    if (_cart.isEmpty) return;

    setState(() => _isProcessingCheckout = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate printing receipt / card swipe

    if (mounted) {
      setState(() {
        _isProcessingCheckout = false;
        _cart.clear();
        _totalAmount = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Checkout Success! Receipt printed.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;
    
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = user.role;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Adaptive appbar
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.businessName ?? 'CloudPOS System',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ACTIVE REGISTER NODE',
                style: GoogleFonts.inter(
                  color: AppColors.onPrimaryContainer,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Plan subscription badge
          if (isDesktop) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'PRO TIER ACTIVE',
                  style: GoogleFonts.inter(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Logged user details chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _getRoleColor(role),
                  child: Text(
                    user.fullName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  role.label,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            tooltip: 'De-authorize Node (Sign Out)',
            onPressed: () async {
              await authController.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _buildAdaptiveBody(role, isDesktop),
    );
  }

  // Adaptive dashboard layout based on UserRole
  Widget _buildAdaptiveBody(UserRole role, bool isDesktop) {
    if (role == UserRole.cashier) {
      // Cashiers immediately land on the Register Checkout Terminal!
      return _buildCheckoutTerminal(isDesktop);
    }

    // Admins and Managers get the broad management dashboard
    return _buildManagementDashboard(role, isDesktop);
  }

  // ─── CASHIER VIEW: CLICKABLE REGISTER TERMINAL ──────────────────────────────
  Widget _buildCheckoutTerminal(bool isDesktop) {
    return Row(
      children: [
        // Product Grid Column
        Expanded(
          flex: isDesktop ? 2 : 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales Registry Catalog',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync),
                      tooltip: 'Sync inventory catalog',
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: _catalog.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      final prod = _catalog[index];
                      return InkWell(
                        onTap: () => _addToCart(prod),
                        borderRadius: BorderRadius.circular(12),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(prod['icon'] as IconData, color: AppColors.secondary, size: 20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod['name'] as String,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(prod['price'] as double).toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Active Cart Panel
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Sale',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                      if (_cart.isNotEmpty)
                        TextButton(
                          onPressed: _clearCart,
                          child: Text('Clear', style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),

                // Cart list
                Expanded(
                  child: _cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.outline.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Terminal cart is empty',
                                style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _cart.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.outlineVariant),
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            final prod = item['product'];
                            final qty = item['quantity'] as int;
                            final cost = (prod['price'] as double) * qty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod['name'] as String,
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$qty x \$${(prod['price'] as double).toStringAsFixed(2)}',
                                          style: GoogleFonts.inter(color: AppColors.outline, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${cost.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                        onPressed: () => _removeFromCart(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Checkout button summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    border: Border(top: BorderSide(color: AppColors.outlineVariant)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL DUE:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.outline)),
                          Text(
                            '\$${_totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_cart.isEmpty || _isProcessingCheckout) ? null : _processCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: _isProcessingCheckout
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.point_of_sale),
                                    SizedBox(width: 8),
                                    Text('PROCESS CHECKOUT'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── ADMIN & MANAGER VIEW: OPERATIONAL PORTAL ──────────────────────────────
  Widget _buildManagementDashboard(UserRole role, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operational Control Room',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, manager. Terminals are active and syncing.',
                      style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!isDesktop) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PRO TIER',
                    style: GoogleFonts.inter(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),

          // Overview stats
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _StatCard(label: 'TODAY SALES', value: '\$1,248.50', icon: Icons.insights, color: AppColors.secondary)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(label: 'ACTIVE REGISTERS', value: '4 Terminal Nodes', icon: Icons.terminal, color: AppColors.accentPurple)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(label: 'DELEGATED EMPLOYEES', value: '8 Active Staff', icon: Icons.group, color: AppColors.accentGreen)),
              ],
            )
          else
            Column(
              children: [
                _StatCard(label: 'TODAY SALES', value: '\$1,248.50', icon: Icons.insights, color: AppColors.secondary),
                const SizedBox(height: 12),
                _StatCard(label: 'ACTIVE REGISTERS', value: '4 Terminal Nodes', icon: Icons.terminal, color: AppColors.accentPurple),
                const SizedBox(height: 12),
                _StatCard(label: 'DELEGATED EMPLOYEES', value: '8 Active Staff', icon: Icons.group, color: AppColors.accentGreen),
              ],
            ),

          const SizedBox(height: 32),

          // Operations title
          Text(
            'Operational Management Modules',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 16),

          // Grid of operational modules
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.45 : 1.1,
            children: [
              _ModuleCard(
                icon: Icons.payments_outlined,
                title: 'Sales Register (Terminal)',
                description: 'Open standard terminal to ring up coffee, pastry, or custom items.',
                color: AppColors.secondary,
                onTap: () {
                  // Admin/Managers can jump into the checkout terminal!
                  // We simulate this by changing the active view role temporarily or displaying register overlay
                  setState(() {
                    // Quick simulated trigger to experience Cashier checkout!
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to Checkout Terminal view.', style: GoogleFonts.inter()),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  });
                  // Temporarily let them act as Cashier for review
                  // _cart.clear();
                  // _totalAmount = 0;
                  // authController.updateBusinessContext(user.businessId!, user.businessName!);
                  // // Navigate to Checkout Terminal by forcing role switch in Mock Session
                  // final updatedUser = authController.currentUser!.copyWith(role: UserRole.cashier);
                  // authController.updateBusinessContext(updatedUser.businessId!, updatedUser.businessName!);
                  // final authSession = UserSession(user: updatedUser, isAuthenticated: true);
                  // // We bypass standard model setter for high-fidelity experience
                },
              ),
              _ModuleCard(
                icon: Icons.inventory_2_outlined,
                title: 'Inventory Control',
                description: 'Manage espresso beans stock, bakery supply thresholds, and barcode sync.',
                color: AppColors.accentAmber,
                onTap: () => _showComingSoon('Inventory Management'),
              ),
              _ModuleCard(
                icon: Icons.people_outline,
                title: 'User Delegation (Staff)',
                description: 'Assign manager, cashier, or register roles to your employees.',
                color: AppColors.accentPurple,
                onTap: () => _showComingSoon('Employee Access Management'),
              ),
              _ModuleCard(
                icon: Icons.bar_chart_outlined,
                title: 'Gross Margin Analytics',
                description: 'Real-time financial charts of active registers and sales volumes.',
                color: AppColors.accentGreen,
                onTap: () => _showComingSoon('Analytics Mainframe'),
              ),
              _ModuleCard(
                icon: Icons.card_membership_outlined,
                title: 'SaaS Billing & Subscription',
                description: 'Adjust Pro monthly tiers, view historical statements, and manage cards.',
                color: Colors.blueGrey,
                onTap: () => _showComingSoon('Billing Panel'),
              ),
              _ModuleCard(
                icon: Icons.settings_outlined,
                title: 'System Terminal Settings',
                description: 'Configure standard printers, receipt footers, and tax percentages.',
                color: Colors.indigo,
                onTap: () => _showComingSoon('Settings Console'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Backend service required: $moduleName will connect to NestJS/Supabase.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.accentGreen;
      case UserRole.manager:
        return AppColors.accentAmber;
      case UserRole.cashier:
        return AppColors.accentPurple;
    }
  }
}

// ─── DASHBOARD WIDGET HELPERS ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(color: AppColors.outline, fontSize: 10, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
