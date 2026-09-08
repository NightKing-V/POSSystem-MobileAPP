import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/domain/mock_data.dart';

/// Card component representing a store branch/location with status toggle.
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
  });

  final MockLocation location;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.hairline.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.inkTeal.withValues(alpha: 0.1)
                    : AppColors.hairline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: isActive ? AppColors.inkTeal : AppColors.slate,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        location.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (location.id == 'loc1') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.inkTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HQ',
                            style: TextStyle(
                              color: AppColors.inkTeal,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.address,
                    style: const TextStyle(fontSize: 12, color: AppColors.slate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isActive,
              onChanged: onToggle,
              activeTrackColor: AppColors.inkTeal.withValues(alpha: 0.5),
              activeThumbColor: AppColors.inkTeal,
            ),
          ],
        ),
      ),
    );
  }
}
