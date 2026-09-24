import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/widgets/billing_summary.dart';
import '../../../inventory/presentation/widgets/product_grid.dart';
import '../../../inventory/presentation/widgets/product_search_bar.dart';
import '../../../customers/data/customers_repository.dart';
import './cart_item_tile.dart';
import './cart_props.dart';
import './customer_section.dart';
import './empty_cart_state.dart';
import './payment_bar.dart';

/// Width of the right-side cart pane on tablet/desktop layouts.
const double _kCartPaneWidth = 380.0;

/// Wide (tablet / desktop) — two-pane side-by-side cashier layout.
class WideCartLayout extends StatelessWidget {
  const WideCartLayout({
    super.key,
    required this.cart,
    required this.products,
    required this.showCustomer,
    required this.onToggleCustomer,
    this.selectedCustomer,
    required this.onCustomerSelected,
    this.orgId,
  });

  final CartProps cart;
  final ProductProps products;
  final bool showCustomer;
  final VoidCallback onToggleCustomer;
  final CustomerProps? selectedCustomer;
  final ValueChanged<CustomerProps?> onCustomerSelected;
  final String? orgId;

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
                    ? CustomerSection(
                        onDismiss: onToggleCustomer,
                        selectedCustomer: selectedCustomer,
                        onCustomerSelected: onCustomerSelected,
                        orgId: orgId,
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: CustomerToggleChip(
                          onTap: onToggleCustomer,
                          selectedCustomer: selectedCustomer,
                        ),
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
                    ? const EmptyCartState()
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
