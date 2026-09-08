import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable animated multi-step progress bar and indicator for auth flows.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.currentIndex,
    required this.labels,
  });

  final int currentIndex;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(labels.length, (i) {
            final active = i == currentIndex;
            final past = i < currentIndex;
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (active || past)
                        ? AppColors.inkTeal
                        : AppColors.hairline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (i < labels.length - 1) const SizedBox(width: 6),
              ],
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Step ${currentIndex + 1} of ${labels.length}: ${labels[currentIndex.clamp(0, labels.length - 1)]}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: AppColors.slate,
              ),
        ),
      ],
    );
  }
}
