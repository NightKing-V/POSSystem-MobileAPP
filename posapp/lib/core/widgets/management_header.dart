import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable management search bar with clean icon and clear button.
class ManagementSearchBar extends StatelessWidget {
  const ManagementSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.width,
    this.height = 40,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13, color: AppColors.ink),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.slate),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.slate, size: 18),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 16, color: AppColors.slate),
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Unified, componentized header with inline search & action controls.
/// - **Desktop & Tablet (>= 600px)**: Renders Title & Subtitle inline with Filters, Search Bar, and Action Buttons in a single top row.
/// - **Mobile (< 600px)**: Renders Title (if enabled), full-width Search Bar + Filters, and provides `buildFab(...)` for primary actions.
class ManagementHeaderBar extends StatelessWidget {
  const ManagementHeaderBar({
    super.key,
    this.title,
    this.subtitle,
    this.itemCountText,
    this.searchCtrl,
    this.searchHint = 'Search…',
    this.onSearchChanged,
    this.actionLabel,
    this.actionIcon = Icons.add,
    this.onActionTap,
    this.filterWidget,
    this.extraActions,
    this.leading,
    this.hideMobileTitle = true,
  });

  final String? title;
  final String? subtitle;
  final String? itemCountText;
  final TextEditingController? searchCtrl;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onActionTap;
  final Widget? filterWidget;
  final List<Widget>? extraActions;
  final Widget? leading;
  final bool hideMobileTitle;

  static bool isDesktopOrTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// Helper to build FloatingActionButton on mobile screens when not on desktop/tablet.
  static Widget? buildFab(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    IconData icon = Icons.add,
  }) {
    if (isDesktopOrTablet(context)) return null;
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: AppColors.inkTeal,
      foregroundColor: Colors.white,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = isDesktopOrTablet(context);

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            if (title != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                      ),
                      if (itemCountText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.inkTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            itemCountText!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.inkTeal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ],
              ),
            ] else if (itemCountText != null) ...[
              Text(
                itemCountText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: AppColors.slate,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            const Spacer(),
            if (filterWidget != null) ...[
              filterWidget!,
              const SizedBox(width: 12),
            ],
            if (searchCtrl != null) ...[
              ManagementSearchBar(
                controller: searchCtrl!,
                hint: searchHint,
                onChanged: onSearchChanged,
                width: 250,
              ),
              const SizedBox(width: 12),
            ],
            if (extraActions != null) ...[
              ...extraActions!,
              const SizedBox(width: 12),
            ],
            if (actionLabel != null && onActionTap != null)
              ElevatedButton.icon(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inkTeal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: Icon(actionIcon, size: 17),
                label: Text(
                  actionLabel!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
          ],
        ),
      );
    }

    // Mobile layout (< 600px)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null && !hideMobileTitle) ...[
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (subtitle != null || itemCountText != null)
                        Text(
                          subtitle ?? itemCountText ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.slate,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (searchCtrl != null)
            ManagementSearchBar(
              controller: searchCtrl!,
              hint: searchHint,
              onChanged: onSearchChanged,
            ),
          if (filterWidget != null) ...[
            const SizedBox(height: 8),
            filterWidget!,
          ],
        ],
      ),
    );
  }
}
