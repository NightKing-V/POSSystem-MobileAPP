import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Search bar for the product panel.
///
/// Styled to match the existing [InputDecorationTheme] with an
/// additional teal barcode-scan icon button (UI only — no real scanner).
class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onScanTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Called when the cashier taps the barcode scanner icon.
  /// Real scanner integration can be wired here later.
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU…',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.slate),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ScanButton(onTap: onScanTap),
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.inkTeal,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.inkTeal.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

