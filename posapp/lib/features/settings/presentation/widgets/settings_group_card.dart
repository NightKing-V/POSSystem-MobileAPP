import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings_tile_item.dart';

/// Clean, reusable container for grouping settings tiles with a section title.
class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingsTileItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.slate,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.hairline.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _SettingsTile(item: items[i]),
                if (i != items.length - 1)
                  const Divider(color: AppColors.hairline, height: 1, indent: 64),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});

  final SettingsTileItem item;

  @override
  Widget build(BuildContext context) {
    final defaultAccent = item.iconColor ?? AppColors.inkTeal;

    return ListTile(
      onTap: item.onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: defaultAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: defaultAccent,
          size: 20,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: item.titleColor ?? AppColors.ink,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.slate),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.badgeText!,
                style: const TextStyle(
                  color: AppColors.inkTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
        ],
      ),
    );
  }
}
