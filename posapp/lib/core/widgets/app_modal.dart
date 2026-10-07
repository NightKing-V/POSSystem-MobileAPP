import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';

/// Screen width breakpoint separating Desktop (hovering dialog) from Tablet/Mobile (slide-in sheet).
const double kResponsiveModalBreakpoint = 800.0;

/// Opens a responsive modal dialog:
/// - **Desktop (>= 800px)**: Centered hovering modal card with dim backdrop & scale-in animation.
/// - **Tablet & Mobile (< 800px)**: Smooth slide-in bottom sheet with drag handle & keyboard avoidance.
Future<T?> showResponsiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  String? subtitle,
  Widget? leadingIcon,
  double maxWidth = 720.0,
  double maxHeightFactor = 0.88,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showHeader = true,
  Widget? bottomBar,
  EdgeInsets? contentPadding,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isDesktop = screenWidth >= kResponsiveModalBreakpoint;

  if (isDesktop) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim1, anim2) {
        return _HoveringModalDialog(
          title: title,
          subtitle: subtitle,
          leadingIcon: leadingIcon,
          maxWidth: maxWidth,
          maxHeightFactor: maxHeightFactor,
          showHeader: showHeader,
          bottomBar: bottomBar,
          contentPadding: contentPadding,
          child: builder(ctx),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  } else {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (ctx) {
        return _SlideInModalSheet(
          title: title,
          subtitle: subtitle,
          leadingIcon: leadingIcon,
          maxHeightFactor: maxHeightFactor,
          showHeader: showHeader,
          bottomBar: bottomBar,
          contentPadding: contentPadding,
          child: builder(ctx),
        );
      },
    );
  }
}

/// Desktop Hovering Modal Container
class _HoveringModalDialog extends StatelessWidget {
  const _HoveringModalDialog({
    required this.child,
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.maxWidth = 720.0,
    this.maxHeightFactor = 0.88,
    this.showHeader = true,
    this.bottomBar,
    this.contentPadding,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leadingIcon;
  final double maxWidth;
  final double maxHeightFactor;
  final bool showHeader;
  final Widget? bottomBar;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxH = screenHeight * maxHeightFactor;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxH),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.hairline.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHeader && (title != null || subtitle != null))
                    ResponsiveModalHeader(
                      title: title ?? '',
                      subtitle: subtitle,
                      leadingIcon: leadingIcon,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  Flexible(
                    child: contentPadding != null
                        ? Padding(padding: contentPadding!, child: child)
                        : child,
                  ),
                  if (bottomBar != null) ...[
                    const Divider(height: 1, color: AppColors.hairline),
                    bottomBar!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tablet & Mobile Slide-In Modal Bottom Sheet Container
class _SlideInModalSheet extends StatelessWidget {
  const _SlideInModalSheet({
    required this.child,
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.maxHeightFactor = 0.90,
    this.showHeader = true,
    this.bottomBar,
    this.contentPadding,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leadingIcon;
  final double maxHeightFactor;
  final bool showHeader;
  final Widget? bottomBar;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFactor),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag pill
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.hairline,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (showHeader && (title != null || subtitle != null))
                  ResponsiveModalHeader(
                    title: title ?? '',
                    subtitle: subtitle,
                    leadingIcon: leadingIcon,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                Flexible(
                  child: contentPadding != null
                      ? Padding(padding: contentPadding!, child: child)
                      : child,
                ),
                if (bottomBar != null) ...[
                  const Divider(height: 1, color: AppColors.hairline),
                  bottomBar!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Modal Header Bar with Title, Subtitle, and Close button
class ResponsiveModalHeader extends StatelessWidget {
  const ResponsiveModalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget? leadingIcon;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: leadingIcon!,
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
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
          ),
          IconButton(
            tooltip: context.tr('common.close'),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.slate,
              size: 22,
            ),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Reusable Form Section Card used inside modals
class ResponsiveModalCard extends StatelessWidget {
  const ResponsiveModalCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.hairline.withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: AppColors.ink,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Reusable Modal Sticky Action Footer (Cancel / Submit buttons)
class ResponsiveModalFooter extends StatelessWidget {
  const ResponsiveModalFooter({
    super.key,
    required this.onSubmit,
    this.onCancel,
    this.submitLabel,
    this.cancelLabel,
    this.isLoading = false,
    this.submitColor,
  });

  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final String? submitLabel;
  final String? cancelLabel;
  final bool isLoading;
  final Color? submitColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(
              cancelLabel ?? context.tr('common.cancel'),
              style: const TextStyle(
                color: AppColors.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: submitColor ?? AppColors.inkTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    submitLabel ?? context.tr('common.save'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
