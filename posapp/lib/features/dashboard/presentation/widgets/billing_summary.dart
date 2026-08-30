import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pos/billing/bill_calculator.dart';
import '../../../pos/domain/models/cart_item.dart';

/// Billing summary panel: item count, subtotal, editable bill-level
/// discount, editable tax %, and the prominent grand total.
///
/// Controllers are owned by the parent state so values survive rebuilds.
class BillingSummary extends StatelessWidget {
  const BillingSummary({
    super.key,
    required this.items,
    required this.billDiscountPct,
    required this.taxPct,
    required this.billDiscountController,
    required this.taxController,
    required this.onBillDiscountChanged,
    required this.onTaxChanged,
  });

  final List<CartItem> items;
  final double billDiscountPct;
  final double taxPct;

  /// Controllers held by the parent; only their initial values are set there.
  final TextEditingController billDiscountController;
  final TextEditingController taxController;

  final ValueChanged<double> onBillDiscountChanged;
  final ValueChanged<double> onTaxChanged;

  @override
  Widget build(BuildContext context) {
    // ── Billing math ────────────────────────────────────────────────────────
    final sub = BillCalculator.subtotal(items);
    final discAmt = BillCalculator.billDiscountAmount(sub, billDiscountPct);
    final taxAmt = BillCalculator.taxAmount(sub - discAmt, taxPct);
    final grand = BillCalculator.grandTotal(
      subtotal: sub,
      billDiscountAmt: discAmt,
      taxAmt: taxAmt,
    );
    final totalItems = items.fold<int>(0, (s, i) => s + i.quantity);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(color: AppColors.hairline.withValues(alpha: 0.7), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item count label
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 13, color: AppColors.slate),
              const SizedBox(width: 5),
              Text(
                '$totalItems ${totalItems == 1 ? 'item' : 'items'} in bill',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Subtotal row
          _SummaryRow(
            label: 'Subtotal',
            value: 'Rs. ${sub.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 7),

          // Bill-level discount (editable %)
          _EditableRow(
            label: 'Bill Discount',
            controller: billDiscountController,
            onChanged: (v) =>
                onBillDiscountChanged((double.tryParse(v) ?? 0.0).clamp(0.0, 100.0)),
            amountText: discAmt > 0
                ? '− Rs. ${discAmt.toStringAsFixed(2)}'
                : 'Rs. 0.00',
            amountColor: discAmt > 0 ? const Color(0xFF16A34A) : AppColors.slate,
          ),
          const SizedBox(height: 7),

          // Tax / VAT (editable %)
          _EditableRow(
            label: 'Tax / VAT',
            controller: taxController,
            onChanged: (v) =>
                onTaxChanged((double.tryParse(v) ?? 0.0).clamp(0.0, 100.0)),
            amountText: '+ Rs. ${taxAmt.toStringAsFixed(2)}',
            amountColor: AppColors.slate,
          ),
          const SizedBox(height: 12),

          const Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 12),

          // Grand Total — most prominent element
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 14),
              ),
              Text(
                'Rs. ${grand.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                      color: AppColors.inkTeal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12, color: AppColors.ink)),
      ],
    );
  }
}

/// A summary row with an editable percentage field and a computed amount.
class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.amountText,
    required this.amountColor,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String amountText;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12)),
        ),
        // Percentage mini-field
        _MiniPercentField(controller: controller, onChanged: onChanged),
        const SizedBox(width: 8),
        // Computed amount (right-aligned, fixed width for alignment)
        SizedBox(
          width: 96,
          child: Text(
            amountText,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: amountColor,
                ),
          ),
        ),
      ],
    );
  }
}

class _MiniPercentField extends StatelessWidget {
  const _MiniPercentField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.hairline, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}(\.\d{0,2})?')),
              ],
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.ink,
                  ),
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
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text('%', style: TextStyle(fontSize: 10, color: AppColors.slate)),
          ),
        ],
      ),
    );
  }
}
