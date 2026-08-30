import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/cart_item.dart';

/// A single row in the cart representing one [CartItem].
///
/// Handles its own sub-state:
///   - Quantity [TextField] (tap-to-edit, synced with stepper buttons)
///   - Collapsible per-item discount row
///
/// The parent is notified via callbacks only when values commit
/// ([onQuantityChanged], [onDiscountChanged], [onRemove]).
class CartItemTile extends StatefulWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onDiscountChanged;
  final VoidCallback onRemove;

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  late final TextEditingController _qtyCtrl;
  final FocusNode _qtyFocus = FocusNode();
  bool _showDiscount = false;
  late final TextEditingController _discountCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    _discountCtrl = TextEditingController(
      text: widget.item.itemDiscountPct > 0
          ? widget.item.itemDiscountPct.toStringAsFixed(0)
          : '',
    );
    // Show discount row automatically if a discount was already applied
    _showDiscount = widget.item.itemDiscountPct > 0;
  }

  @override
  void didUpdateWidget(covariant CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync the text field while the user is NOT actively typing in it.
    if (!_qtyFocus.hasFocus &&
        oldWidget.item.quantity != widget.item.quantity) {
      _qtyCtrl.text = widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _discountCtrl.dispose();
    _qtyFocus.dispose();
    super.dispose();
  }

  void _commitQty(String raw) {
    final parsed = int.tryParse(raw);
    if (parsed != null && parsed > 0) widget.onQuantityChanged(parsed);
  }

  void _commitDiscount(String raw) {
    final parsed = double.tryParse(raw) ?? 0.0;
    widget.onDiscountChanged(parsed.clamp(0.0, 100.0));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline.withValues(alpha: 0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Product name + SKU ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontSize: 12.5,
                              color: AppColors.ink,
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.product.sku}  ·  Rs. ${item.unitPrice.toStringAsFixed(0)} ea',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // ── Quantity stepper ───────────────────────────────────────
                _QuantityStepper(
                  controller: _qtyCtrl,
                  focusNode: _qtyFocus,
                  onDecrement: () => widget.onQuantityChanged(item.quantity - 1),
                  onIncrement: () => widget.onQuantityChanged(item.quantity + 1),
                  onTextChanged: _commitQty,
                ),
                const SizedBox(width: 10),

                // ── Line total ─────────────────────────────────────────────
                SizedBox(
                  width: 72,
                  child: Text(
                    'Rs. ${item.lineTotal.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13,
                          color: AppColors.inkTeal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // ── Action icons ───────────────────────────────────────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TileIconBtn(
                      icon: Icons.close_rounded,
                      color: AppColors.error,
                      onTap: widget.onRemove,
                    ),
                    _TileIconBtn(
                      icon: Icons.percent_rounded,
                      color: _showDiscount ? AppColors.inkTeal : AppColors.slate.withValues(alpha: 0.5),
                      onTap: () => setState(() => _showDiscount = !_showDiscount),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Collapsible per-item discount row ──────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showDiscount
                ? _ItemDiscountRow(
                    controller: _discountCtrl,
                    lineSubtotal: item.lineSubtotal,
                    discountPct: item.itemDiscountPct,
                    onChanged: _commitDiscount,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.controller,
    required this.focusNode,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTextChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(icon: Icons.remove_rounded, onTap: onDecrement),
        SizedBox(
          width: 34,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onTextChanged,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 13, color: AppColors.ink),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
        _StepBtn(icon: Icons.add_rounded, onTap: onIncrement),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.inkTeal.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 13, color: AppColors.inkTeal),
      ),
    );
  }
}

class _TileIconBtn extends StatelessWidget {
  const _TileIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _ItemDiscountRow extends StatelessWidget {
  const _ItemDiscountRow({
    required this.controller,
    required this.lineSubtotal,
    required this.discountPct,
    required this.onChanged,
  });

  final TextEditingController controller;
  final double lineSubtotal;
  final double discountPct;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final saving = lineSubtotal * discountPct / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          Text(
            'Item discount:',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 11, color: AppColors.slate),
          ),
          const SizedBox(width: 8),
          // Percentage input
          Container(
            width: 70,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.marigold.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.marigold.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
                    ],
                    onChanged: onChanged,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontSize: 11, color: AppColors.ink),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0',
                      contentPadding: EdgeInsets.symmetric(vertical: 7),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Text('%', style: TextStyle(fontSize: 11, color: AppColors.slate)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (saving > 0)
            Text(
              '− Rs. ${saving.toStringAsFixed(0)} saved',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF16A34A),
                  ),
            ),
        ],
      ),
    );
  }
}
