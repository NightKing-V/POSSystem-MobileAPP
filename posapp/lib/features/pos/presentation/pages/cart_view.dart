import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../billing/bill_calculator.dart';
import '../../domain/models/cart_item.dart';
import '../../../inventory/domain/models/product.dart';
import '../../../dashboard/presentation/widgets/billing_summary.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_bar.dart';
import '../../../inventory/presentation/widgets/product_grid.dart';
import '../../../inventory/presentation/widgets/product_search_bar.dart';

import '../../data/bills_repository.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/api/api_helper.dart';

/// Breakpoint in logical pixels separating phone (narrow) from tablet/desktop.
const double _kWideBreakpoint = 600.0;

/// Width of the right-side cart pane on tablet/desktop layouts.
const double _kCartPaneWidth = 380.0;

// =============================================================================
// CartView — cashier billing feature connected to API
// =============================================================================

/// The cashier billing screen.
class CartView extends StatefulWidget {
  const CartView({
    super.key,
    this.orgId,
    this.locationId,
  });

  final String? orgId;
  final String? locationId;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _billsRepo = BillsRepository();
  final _inventoryRepo = InventoryRepository();

  List<Product> _allProducts = Product.mockProducts;

  // ── Cart ──────────────────────────────────────────────────────────────────
  /// Pre-populated with sample items so the UI is immediately demonstrable.
  final List<CartItem> _cartItems = [
    CartItem(product: Product.mockProducts[0], quantity: 2),
    CartItem(product: Product.mockProducts[2], quantity: 1),
    CartItem(product: Product.mockProducts[7], quantity: 3),
  ];

  // ── Product search ─────────────────────────────────────────────────────────
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Billing inputs ─────────────────────────────────────────────────────────
  double _billDiscountPct = 0.0;
  double _taxPct = 15.0;
  late final TextEditingController _billDiscountCtrl;
  late final TextEditingController _taxCtrl;

  // ── Payment ────────────────────────────────────────────────────────────────
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  // ── UI toggles ─────────────────────────────────────────────────────────────
  bool _showProductPanel = false; // phone: expand/collapse product grid
  bool _showCustomer = false;     // collapsible customer lookup section

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _billDiscountCtrl = TextEditingController(text: '0');
    _taxCtrl = TextEditingController(text: '15');
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _inventoryRepo.fetchProducts();
    if (!mounted) return;
    if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
      setState(() {
        _allProducts = response.data!;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _billDiscountCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    final q = _searchQuery.toLowerCase();
    return _allProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  double get _grandTotal {
    final sub = BillCalculator.subtotal(_cartItems);
    final disc = BillCalculator.billDiscountAmount(sub, _billDiscountPct);
    final tax = BillCalculator.taxAmount(sub - disc, _taxPct);
    return BillCalculator.grandTotal(
        subtotal: sub, billDiscountAmt: disc, taxAmt: tax);
  }

  // ── Cart mutations ─────────────────────────────────────────────────────────

  void _addProduct(Product product) {
    setState(() {
      final idx = _cartItems.indexWhere((i) => i.product.id == product.id);
      if (idx >= 0) {
        _cartItems[idx].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _onQuantityChanged(int index, int newQty) {
    setState(() {
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQty;
      }
    });
  }

  void _onItemDiscountChanged(int index, double pct) {
    setState(() => _cartItems[index].itemDiscountPct = pct);
  }

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _clearCart() {
    setState(() => _cartItems.clear());
  }

  // ── Action handlers (UI-only) ──────────────────────────────────────────────

  void _onScanTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Barcode scanner ready — point camera at a product barcode.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onHoldBill() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.pause_circle_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Bill held. Resume it any time from the Held Bills list.'),
          ],
        ),
        backgroundColor: AppColors.inkTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onClearTap() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Clear Bill?',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.ink)),
          ],
        ),
        content: const Text(
            'All items will be removed from the current bill. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.slate)),
          ),
          TextButton(
            onPressed: () {
              _clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear Bill',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _onCharge() async {
    if (_cartItems.isEmpty) {
      ApiHelper.showErrorSnackBar(context, 'Cart is empty');
      return;
    }

    final method = _paymentMethod.name[0].toUpperCase() +
        _paymentMethod.name.substring(1);

    final currentUser = TokenStorage.getCurrentUser();
    final cashierId = currentUser?['id']?.toString() ?? '00000000-0000-0000-0000-000000000000';
    final orgId = widget.orgId ?? '00000000-0000-0000-0000-000000000000';
    final locationId = widget.locationId ?? '00000000-0000-0000-0000-000000000000';

    final billDto = CreateBillDto(
      orgId: orgId,
      locationId: locationId,
      cashierId: cashierId,
      taxes: [
        BillTaxDto(name: 'VAT', rate: _taxPct, isActive: true),
      ],
      items: _cartItems
          .map((item) => BillItemDto(
                productId: item.product.id,
                quantity: item.quantity,
                notes: item.itemDiscountPct > 0
                    ? 'Item discount: ${item.itemDiscountPct}%'
                    : null,
              ))
          .toList(),
      payments: [
        BillPaymentDto(
          paymentMethod: _paymentMethod.name.toUpperCase(),
          amount: _grandTotal,
        ),
      ],
    );

    // Call API in background
    _billsRepo.createBill(billDto);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF16A34A), size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              'Sale Complete!',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Rs. ${_grandTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 28,
                    color: AppColors.inkTeal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Payment received via $method',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt_outlined, size: 18),
              label: const Text('New Bill',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                _clearCart();
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kWideBreakpoint;

        // Shared child props assembled once to avoid repetition.
        final cartProps = _CartProps(
          cartItems: _cartItems,
          grandTotal: _grandTotal,
          paymentMethod: _paymentMethod,
          billDiscountPct: _billDiscountPct,
          taxPct: _taxPct,
          billDiscountCtrl: _billDiscountCtrl,
          taxCtrl: _taxCtrl,
          onQuantityChanged: _onQuantityChanged,
          onItemDiscountChanged: _onItemDiscountChanged,
          onRemove: _removeItem,
          onBillDiscountChanged: (v) => setState(() => _billDiscountPct = v),
          onTaxChanged: (v) => setState(() => _taxPct = v),
          onMethodChanged: (m) => setState(() => _paymentMethod = m),
          onHoldBill: _onHoldBill,
          onClear: _onClearTap,
          onCharge: _onCharge,
        );

        final productProps = _ProductProps(
          filteredProducts: _filteredProducts,
          searchCtrl: _searchCtrl,
          onSearch: (q) => setState(() => _searchQuery = q),
          onScanTap: _onScanTap,
          onProductTap: _addProduct,
        );

        return isWide
            ? _WideLayout(
                cart: cartProps,
                products: productProps,
                showCustomer: _showCustomer,
                onToggleCustomer: () =>
                    setState(() => _showCustomer = !_showCustomer),
              )
            : _NarrowLayout(
                cart: cartProps,
                products: productProps,
                showProductPanel: _showProductPanel,
                showCustomer: _showCustomer,
                onToggleProductPanel: () =>
                    setState(() => _showProductPanel = !_showProductPanel),
                onToggleCustomer: () =>
                    setState(() => _showCustomer = !_showCustomer),
              );
      },
    );
  }
}

// =============================================================================
// Data transfer objects — avoid repeating long parameter lists
// =============================================================================

class _CartProps {
  const _CartProps({
    required this.cartItems,
    required this.grandTotal,
    required this.paymentMethod,
    required this.billDiscountPct,
    required this.taxPct,
    required this.billDiscountCtrl,
    required this.taxCtrl,
    required this.onQuantityChanged,
    required this.onItemDiscountChanged,
    required this.onRemove,
    required this.onBillDiscountChanged,
    required this.onTaxChanged,
    required this.onMethodChanged,
    required this.onHoldBill,
    required this.onClear,
    required this.onCharge,
  });

  final List<CartItem> cartItems;
  final double grandTotal;
  final PaymentMethod paymentMethod;
  final double billDiscountPct;
  final double taxPct;
  final TextEditingController billDiscountCtrl;
  final TextEditingController taxCtrl;
  final void Function(int index, int qty) onQuantityChanged;
  final void Function(int index, double pct) onItemDiscountChanged;
  final ValueChanged<int> onRemove;
  final ValueChanged<double> onBillDiscountChanged;
  final ValueChanged<double> onTaxChanged;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final VoidCallback onHoldBill;
  final VoidCallback onClear;
  final VoidCallback onCharge;
}

class _ProductProps {
  const _ProductProps({
    required this.filteredProducts,
    required this.searchCtrl,
    required this.onSearch,
    required this.onScanTap,
    required this.onProductTap,
  });

  final List<Product> filteredProducts;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final VoidCallback onScanTap;
  final ValueChanged<Product> onProductTap;
}

// =============================================================================
// Wide (tablet / desktop) — two-pane side-by-side layout
// =============================================================================

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.cart,
    required this.products,
    required this.showCustomer,
    required this.onToggleCustomer,
  });

  final _CartProps cart;
  final _ProductProps products;
  final bool showCustomer;
  final VoidCallback onToggleCustomer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left: product search + grid ──────────────────────────────────
        Expanded(
          child: Column(
            children: [
              // Customer section (collapsible)
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: showCustomer
                    ? _CustomerSection(onDismiss: onToggleCustomer)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _CustomerToggleChip(onTap: onToggleCustomer),
                      ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: ProductSearchBar(
                  controller: products.searchCtrl,
                  onChanged: products.onSearch,
                  onScanTap: products.onScanTap,
                ),
              ),
              // Product grid (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: ProductGrid(
                    products: products.filteredProducts,
                    onProductTap: products.onProductTap,
                    crossAxisCount: 3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Vertical divider ─────────────────────────────────────────────
        Container(
          width: 1.5,
          color: AppColors.hairline.withValues(alpha: 0.6),
        ),

        // ── Right: cart panel (fixed width) ──────────────────────────────
        SizedBox(
          width: _kCartPaneWidth,
          child: Column(
            children: [
              // Cart list
              Expanded(
                child: cart.cartItems.isEmpty
                    ? const _EmptyCartState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                        itemCount: cart.cartItems.length,
                        itemBuilder: (_, i) => CartItemTile(
                          key: ValueKey(cart.cartItems[i].product.id),
                          item: cart.cartItems[i],
                          onQuantityChanged: (q) =>
                              cart.onQuantityChanged(i, q),
                          onDiscountChanged: (p) =>
                              cart.onItemDiscountChanged(i, p),
                          onRemove: () => cart.onRemove(i),
                        ),
                      ),
              ),
              // Billing summary
              if (cart.cartItems.isNotEmpty)
                BillingSummary(
                  items: cart.cartItems,
                  billDiscountPct: cart.billDiscountPct,
                  taxPct: cart.taxPct,
                  billDiscountController: cart.billDiscountCtrl,
                  taxController: cart.taxCtrl,
                  onBillDiscountChanged: cart.onBillDiscountChanged,
                  onTaxChanged: cart.onTaxChanged,
                ),
              // Payment bar (always visible)
              PaymentBar(
                selectedMethod: cart.paymentMethod,
                grandTotal: cart.grandTotal,
                hasItems: cart.cartItems.isNotEmpty,
                onMethodChanged: cart.onMethodChanged,
                onHoldBill: cart.onHoldBill,
                onClear: cart.onClear,
                onCharge: cart.onCharge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Narrow (phone) — single-column with collapsible product panel
// =============================================================================

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.cart,
    required this.products,
    required this.showProductPanel,
    required this.showCustomer,
    required this.onToggleProductPanel,
    required this.onToggleCustomer,
  });

  final _CartProps cart;
  final _ProductProps products;
  final bool showProductPanel;
  final bool showCustomer;
  final VoidCallback onToggleProductPanel;
  final VoidCallback onToggleCustomer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar + "Add Products" toggle ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: ProductSearchBar(
                  controller: products.searchCtrl,
                  onChanged: products.onSearch,
                  onScanTap: products.onScanTap,
                ),
              ),
              const SizedBox(width: 8),
              _PanelToggleBtn(
                expanded: showProductPanel,
                onTap: onToggleProductPanel,
              ),
            ],
          ),
        ),

        // ── Collapsible product grid ───────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: showProductPanel ? 258 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ProductGrid(
              products: products.filteredProducts,
              onProductTap: products.onProductTap,
            ),
          ),
        ),

        // ── Customer chip (inline on phone) ───────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: showCustomer
              ? _CustomerSection(onDismiss: onToggleCustomer)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _CustomerToggleChip(onTap: onToggleCustomer),
                ),
        ),

        // ── Cart section header ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                'Cart',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 6),
              if (cart.cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.inkTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${cart.cartItems.fold<int>(0, (s, i) => s + i.quantity)}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkTeal),
                  ),
                ),
            ],
          ),
        ),

        // ── Cart items (scrollable, fills remaining space) ─────────────────
        Expanded(
          child: cart.cartItems.isEmpty
              ? const _EmptyCartState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (_, i) => CartItemTile(
                    key: ValueKey(cart.cartItems[i].product.id),
                    item: cart.cartItems[i],
                    onQuantityChanged: (q) => cart.onQuantityChanged(i, q),
                    onDiscountChanged: (p) => cart.onItemDiscountChanged(i, p),
                    onRemove: () => cart.onRemove(i),
                  ),
                ),
        ),

        // ── Billing summary (above sticky bar) ────────────────────────────
        if (cart.cartItems.isNotEmpty)
          BillingSummary(
            items: cart.cartItems,
            billDiscountPct: cart.billDiscountPct,
            taxPct: cart.taxPct,
            billDiscountController: cart.billDiscountCtrl,
            taxController: cart.taxCtrl,
            onBillDiscountChanged: cart.onBillDiscountChanged,
            onTaxChanged: cart.onTaxChanged,
          ),

        // ── Sticky payment bar ─────────────────────────────────────────────
        PaymentBar(
          selectedMethod: cart.paymentMethod,
          grandTotal: cart.grandTotal,
          hasItems: cart.cartItems.isNotEmpty,
          onMethodChanged: cart.onMethodChanged,
          onHoldBill: cart.onHoldBill,
          onClear: cart.onClear,
          onCharge: cart.onCharge,
        ),
      ],
    );
  }
}

// =============================================================================
// Shared utility widgets
// =============================================================================

/// Empty cart state shown in the cart pane when there are no items.
class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.point_of_sale_outlined,
                size: 44,
                color: AppColors.inkTeal.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cart is empty',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan or search a product to\nstart billing',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsible customer lookup section (UI only — no real lookup).
class _CustomerSection extends StatefulWidget {
  const _CustomerSection({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<_CustomerSection> {
  String _customerName = '';
  bool _isWalkIn = true;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.slate),
              const SizedBox(width: 5),
              Text(
                'Customer',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 12),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onDismiss,
                child: const Icon(Icons.keyboard_arrow_up_rounded,
                    size: 18, color: AppColors.slate),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CustomerChip(
                label: 'Walk-in',
                selected: _isWalkIn,
                onTap: () => setState(() {
                  _isWalkIn = true;
                  _customerName = '';
                  _ctrl.clear();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  enabled: !_isWalkIn || _customerName.isNotEmpty,
                  onChanged: (v) => setState(() => _customerName = v),
                  onTap: () => setState(() => _isWalkIn = false),
                  decoration: const InputDecoration(
                    hintText: 'Search customer name…',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          if (!_isWalkIn && _customerName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Customer: $_customerName',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11, color: AppColors.inkTeal),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.inkTeal : AppColors.hairline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.slate,
          ),
        ),
      ),
    );
  }
}

/// Compact chip shown when the customer section is collapsed.
class _CustomerToggleChip extends StatelessWidget {
  const _CustomerToggleChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hairline, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded,
                size: 14, color: AppColors.slate),
            const SizedBox(width: 5),
            Text(
              'Walk-in Customer',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}

/// Toggle button for showing/hiding the product panel on narrow layouts.
class _PanelToggleBtn extends StatelessWidget {
  const _PanelToggleBtn({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: expanded
              ? AppColors.inkTeal.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: expanded ? AppColors.inkTeal : AppColors.hairline,
            width: 1.5,
          ),
        ),
        child: Icon(
          expanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.grid_view_rounded,
          size: 22,
          color: expanded ? AppColors.inkTeal : AppColors.slate,
        ),
      ),
    );
  }
}

