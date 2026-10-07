import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Empty cart placeholder illustration and message.
class EmptyCartState extends StatelessWidget {
  const EmptyCartState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.point_of_sale_outlined,
                size: 44,
                color: AppColors.inkTeal.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('pos.empty_cart'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('pos.empty_cart_hint'),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
