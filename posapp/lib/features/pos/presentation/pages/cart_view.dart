import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../customers/data/customers_repository.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../../../inventory/domain/models/product.dart';
import '../../billing/bill_calculator.dart';
import '../../data/bills_repository.dart';
import '../../domain/models/cart_item.dart';
import '../widgets/cart_props.dart';
import '../widgets/narrow_cart_layout.dart';
import '../widgets/payment_bar.dart';
import '../widgets/wide_cart_layout.dart';

/// Breakpoint in logical pixels separating phone (narrow) from tablet/desktop.
const double _kWideBreakpoint = 600.0;

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

  List<Product> _allProducts = [];

  // ── Cart ──────────────────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];
  CustomerProps? _selectedCustomer;

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
  bool _showProductPanel = false;
  bool _showCustomer = false;

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
      subtotal: sub,
      billDiscountAmt: disc,
      taxAmt: tax,
    );
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

  void _onScanTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanner opened'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onHoldBill() {
    if (_cartItems.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bill with ${_cartItems.length} items put on hold',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.inkTeal,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _onClearTap() {
    if (_cartItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to remove all items from the current bill?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.slate)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _onCharge() async {
    if (_cartItems.isEmpty) return;

    if (!TokenStorage.isAuthenticated) {
      ApiHelper.showErrorSnackBar(
        context,
        'Session expired or not signed in. Please sign in again.',
      );
      return;
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.inkTeal),
      ),
    );

    final subtotal = BillCalculator.subtotal(_cartItems);
    final discAmt = BillCalculator.billDiscountAmount(subtotal, _billDiscountPct);
    final taxable = subtotal - discAmt;
    final taxAmt = BillCalculator.taxAmount(taxable, _taxPct);
    final grandTotal = BillCalculator.grandTotal(
      subtotal: subtotal,
      billDiscountAmt: discAmt,
      taxAmt: taxAmt,
    );

    final billItems = _cartItems.map((item) {
      return BillItemDto(
        productId: item.product.id,
        quantity: item.quantity,
      );
    }).toList();

    final user = TokenStorage.getCurrentUser();
    final cashierId = (user?['id'] ?? user?['userId'] ?? 'cashier').toString();

    final dto = CreateBillDto(
      orgId: widget.orgId ?? '',
      locationId: widget.locationId ?? '',
      cashierId: cashierId,
      customerId: _selectedCustomer?.id,
      items: billItems,
      payments: [
        BillPaymentDto(
          paymentMethod: _paymentMethod.name.toUpperCase(),
          amount: grandTotal,
        ),
      ],
      taxes: _taxPct > 0
          ? [BillTaxDto(name: 'Sales Tax', rate: _taxPct)]
          : null,
    );

    final response = await _billsRepo.createBill(dto);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

    if (response.isSuccess) {
      final billNum = response.data?['billNumber'] ??
          response.data?['id'] ??
          '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      _showReceiptSheet(grandTotal, billNum.toString());
      _clearCart();
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        response.errorMessage ?? 'Failed to complete sale.',
      );
    }
  }

  void _showReceiptSheet(double total, String billNum) {
    showResponsiveModal(
      context: context,
      maxWidth: 440,
      maxHeightFactor: 0.60,
      showHeader: false,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF16A34A),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Receipt $billNum',
              style: const TextStyle(fontSize: 13, color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Paid',
                      style: TextStyle(color: AppColors.slate)),
                  Text(
                    'Rs. ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inkTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kWideBreakpoint;

        final cartProps = CartProps(
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

        final productProps = ProductProps(
          filteredProducts: _filteredProducts,
          searchCtrl: _searchCtrl,
          onSearch: (q) => setState(() => _searchQuery = q),
          onScanTap: _onScanTap,
          onProductTap: _addProduct,
        );

        return isWide
            ? WideCartLayout(
                cart: cartProps,
                products: productProps,
                showCustomer: _showCustomer,
                onToggleCustomer: () =>
                    setState(() => _showCustomer = !_showCustomer),
                selectedCustomer: _selectedCustomer,
                onCustomerSelected: (c) =>
                    setState(() => _selectedCustomer = c),
                orgId: widget.orgId,
              )
            : NarrowCartLayout(
                cart: cartProps,
                products: productProps,
                showProductPanel: _showProductPanel,
                showCustomer: _showCustomer,
                onToggleProductPanel: () =>
                    setState(() => _showProductPanel = !_showProductPanel),
                onToggleCustomer: () =>
                    setState(() => _showCustomer = !_showCustomer),
                selectedCustomer: _selectedCustomer,
                onCustomerSelected: (c) =>
                    setState(() => _selectedCustomer = c),
                orgId: widget.orgId,
              );
      },
    );
  }
}
