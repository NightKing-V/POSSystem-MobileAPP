import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/domain/models/product.dart';

/// Mutable line item data holder for purchase orders.
class PoLineItem {
  PoLineItem({
    required this.product,
    required this.qtyCtrl,
    required this.costCtrl,
  });

  final Product product;
  final TextEditingController qtyCtrl;
  final TextEditingController costCtrl;

  double get lineTotal =>
      (int.tryParse(qtyCtrl.text) ?? 0) *
      (double.tryParse(costCtrl.text) ?? 0.0);

  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
  }
}

/// Row component for an item added to a Purchase Order.
class PoLineItemRow extends StatelessWidget {
  const PoLineItemRow({
    super.key,
    required this.line,
    required this.onRemove,
    required this.onChanged,
  });

  final PoLineItem line;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.hairline.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PoMiniField(
                  controller: line.qtyCtrl,
                  label: 'Qty',
                  numeric: true,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PoMiniField(
                  controller: line.costCtrl,
                  label: 'Unit Cost (Rs.)',
                  decimal: true,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 10, color: AppColors.slate),
                    ),
                    Text(
                      'Rs. ${line.lineTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.inkTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PoMiniField extends StatelessWidget {
  const PoMiniField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.numeric = false,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool numeric;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.slate),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: [
            if (numeric) FilteringTextInputFormatter.digitsOnly,
            if (decimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
