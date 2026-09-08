import 'package:flutter/material.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';

/// Modal bottom sheet for language selection.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = LocaleController().currentLanguageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language_rounded, color: AppColors.inkTeal, size: 24),
                const SizedBox(width: 12),
                Text(
                  context.tr('settings.select_language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final lang in AppLocales.supportedLanguages) ...[
              ListTile(
                onTap: () {
                  LocaleController().changeLanguage(lang.code);
                  Navigator.of(context).pop();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: currentCode == lang.code
                    ? AppColors.inkTeal.withValues(alpha: 0.08)
                    : Colors.transparent,
                leading: Text(
                  lang.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  lang.nativeName,
                  style: TextStyle(
                    fontWeight: currentCode == lang.code ? FontWeight.bold : FontWeight.w500,
                    color: currentCode == lang.code ? AppColors.inkTeal : AppColors.ink,
                  ),
                ),
                subtitle: Text(
                  lang.name,
                  style: const TextStyle(fontSize: 12, color: AppColors.slate),
                ),
                trailing: currentCode == lang.code
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.inkTeal)
                    : null,
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
