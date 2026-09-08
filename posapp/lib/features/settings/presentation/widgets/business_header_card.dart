import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Top profile card displaying active store avatar, business title, and admin badge.
class BusinessHeaderCard extends StatelessWidget {
  const BusinessHeaderCard({
    super.key,
    required this.businessName,
  });

  final String businessName;

  @override
  Widget build(BuildContext context) {
    final initial = businessName.trim().isNotEmpty
        ? businessName.trim().substring(0, 1).toUpperCase()
        : 'B';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.hairline.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.inkTeal,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName.isNotEmpty ? businessName : 'Business',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Store Admin · Active Session',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
