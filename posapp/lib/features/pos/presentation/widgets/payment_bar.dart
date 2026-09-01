import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// The cashier's payment method options.
enum PaymentMethod { cash, card, wallet }

/// Sticky bottom bar with:
///   • Payment method selector (Cash / Card / Wallet chips)
///   • Hold Bill action (ghost button)
///   • Clear bill action (ghost button, destructive)
///   • Charge / Complete Sale CTA (primary, disabled when cart is empty)
class PaymentBar extends StatelessWidget {
  const PaymentBar({
    super.key,
    required this.selectedMethod,
    required this.grandTotal,
    required this.hasItems,
    required this.onMethodChanged,
    required this.onHoldBill,
    required this.onClear,
    required this.onCharge,
  });

  final PaymentMethod selectedMethod;
  final double grandTotal;
  final bool hasItems;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final VoidCallback onHoldBill;
  final VoidCallback onClear;
  final VoidCallback onCharge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Payment method chips ──────────────────────────────────────────
          Row(
            children: [
              Text(
                'Pay via',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 10),
              _PayChip(
                label: 'Cash',
                icon: Icons.payments_outlined,
                selected: selectedMethod == PaymentMethod.cash,
                onTap: () => onMethodChanged(PaymentMethod.cash),
              ),
              const SizedBox(width: 6),
              _PayChip(
                label: 'Card',
                icon: Icons.credit_card_rounded,
                selected: selectedMethod == PaymentMethod.card,
                onTap: () => onMethodChanged(PaymentMethod.card),
              ),
              const SizedBox(width: 6),
              _PayChip(
                label: 'Wallet',
                icon: Icons.account_balance_wallet_outlined,
                selected: selectedMethod == PaymentMethod.wallet,
                onTap: () => onMethodChanged(PaymentMethod.wallet),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Action row ────────────────────────────────────────────────────
          Row(
            children: [
              // Hold bill
              _GhostBtn(
                label: 'Hold',
                icon: Icons.pause_circle_outline_rounded,
                color: AppColors.slate,
                enabled: hasItems,
                onTap: onHoldBill,
              ),
              const SizedBox(width: 6),
              // Clear bill
              _GhostBtn(
                label: 'Clear',
                icon: Icons.delete_sweep_outlined,
                color: AppColors.error,
                enabled: hasItems,
                onTap: onClear,
              ),
              const SizedBox(width: 8),
              // Charge CTA — fills remaining width
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: hasItems ? onCharge : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inkTeal,
                      disabledBackgroundColor: AppColors.hairline,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 17),
                        const SizedBox(width: 5),
                        Text(
                          'Charge  Rs. ${grandTotal.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
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
// Private sub-widgets
// ---------------------------------------------------------------------------

class _PayChip extends StatelessWidget {
  const _PayChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.inkTeal : AppColors.hairline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13,
                color: selected ? Colors.white : AppColors.slate),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  const _GhostBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppColors.hairline;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

