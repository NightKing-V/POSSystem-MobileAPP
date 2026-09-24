import 'package:flutter/material.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';

/// Modal sheet / dialog for language selection.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showResponsiveModal(
      context: context,
      title: context.tr('settings.select_language'),
      subtitle: 'Change app display language',
      leadingIcon: const Icon(Icons.language_rounded, color: AppColors.inkTeal, size: 20),
      maxWidth: 460,
      maxHeightFactor: 0.65,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = LocaleController().currentLanguageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
    );
  }
}
