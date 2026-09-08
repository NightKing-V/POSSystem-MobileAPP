import 'package:flutter/material.dart';
import '../../../inventory/domain/models/product.dart';
import '../../domain/models/cart_item.dart';
import './payment_bar.dart';

/// Props bundle for cart actions and state.
class CartProps {
  const CartProps({
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

/// Props bundle for product catalog and search.
class ProductProps {
  const ProductProps({
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
