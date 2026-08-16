import '../domain/models/cart_item.dart';

/// Pure billing math — no state, no Flutter dependencies.
///
/// All methods are static so the class is trivial to unit-test
/// and easy to replace with server-side calculations later.
///
/// Calculation order:
///   1. [subtotal]          → sum of per-item line totals (after item discounts)
///   2. [billDiscountAmount] → bill-level percentage discount off the subtotal
///   3. [taxAmount]          → VAT/tax applied *after* bill discount
///   4. [grandTotal]         → subtotal − bill discount + tax
class BillCalculator {
  const BillCalculator._();

  /// Sum of every [CartItem.lineTotal] (each already net of item-level discounts).
  static double subtotal(List<CartItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Bill-level discount amount.
  /// [billDiscountPct] must be in the range 0–100.
  static double billDiscountAmount(double subtotal, double billDiscountPct) =>
      subtotal * billDiscountPct / 100;

  /// Tax/VAT applied to the post-discount amount.
  /// [taxPct] must be in the range 0–100.
  static double taxAmount(double discountedSubtotal, double taxPct) =>
      discountedSubtotal * taxPct / 100;

  /// Grand total charged to the customer.
  static double grandTotal({
    required double subtotal,
    required double billDiscountAmt,
    required double taxAmt,
  }) =>
      subtotal - billDiscountAmt + taxAmt;
}
