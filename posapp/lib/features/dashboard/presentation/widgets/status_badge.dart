import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';

/// Reusable PO status badge chip.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final PurchaseOrderStatus status;

  static Color _bg(PurchaseOrderStatus s) {
    switch (s) {
      case PurchaseOrderStatus.draft:             return AppColors.slate;
      case PurchaseOrderStatus.sent:             return const Color(0xFF2563EB);
      case PurchaseOrderStatus.partiallyReceived: return const Color(0xFFD97706);
      case PurchaseOrderStatus.received:          return const Color(0xFF16A34A);
      case PurchaseOrderStatus.cancelled:         return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _bg(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(70), width: 1),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
