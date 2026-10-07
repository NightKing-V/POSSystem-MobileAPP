import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
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

/// Narrow (phone) — single-column layout with collapsible product drawer & sticky payment bar.
class NarrowCartLayout extends StatelessWidget {
  const NarrowCartLayout({
    super.key,
    required this.cart,
    required this.products,
    required this.showProductPanel,
    required this.showCustomer,
    required this.onToggleProductPanel,
    required this.onToggleCustomer,
    this.selectedCustomer,
    required this.onCustomerSelected,
    this.orgId,
  });

  final CartProps cart;
  final ProductProps products;
  final bool showProductPanel;
  final bool showCustomer;
  final VoidCallback onToggleProductPanel;
  final VoidCallback onToggleCustomer;
  final CustomerProps? selectedCustomer;
  final ValueChanged<CustomerProps?> onCustomerSelected;
  final String? orgId;

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
              ? CustomerSection(
                  onDismiss: onToggleCustomer,
                  selectedCustomer: selectedCustomer,
                  onCustomerSelected: onCustomerSelected,
                  orgId: orgId,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CustomerToggleChip(
                    onTap: onToggleCustomer,
                    selectedCustomer: selectedCustomer,
                  ),
                ),
        ),

        // ── Cart section header ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                context.tr('pos.cart'),
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
                      color: AppColors.inkTeal,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Cart items (scrollable, fills remaining space) ─────────────────
        Expanded(
          child: cart.cartItems.isEmpty
              ? const EmptyCartState()
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
