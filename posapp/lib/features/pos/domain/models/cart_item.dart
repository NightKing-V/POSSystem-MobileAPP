import '../../../inventory/domain/models/product.dart';

/// Mutable cart line-item.
///
/// Wraps a [Product] with a [quantity] and an optional
/// per-item [itemDiscountPct] (0–100 %).
/// All price computations are derived properties so there
/// is never stale cached data.
class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
    this.itemDiscountPct = 0.0,
  });

  final Product product;
  int quantity;

  /// Per-item percentage discount (0 = no discount, 100 = free).
  double itemDiscountPct;

  // ---------------------------------------------------------------------------
  // Derived getters — computed on every access, never cached.
  // ---------------------------------------------------------------------------

  double get unitPrice => product.price;

  double get lineSubtotal => unitPrice * quantity;

  /// Saving from the per-item discount.
  double get lineDiscountAmount => lineSubtotal * itemDiscountPct / 100;

  /// Net line total after per-item discount.
  double get lineTotal => lineSubtotal - lineDiscountAmount;
}
