import 'package:flutter/material.dart';
import '../../../../core/localization/app_locales.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';
import './locations_list_view.dart';
import '../../../staff/presentation/pages/permission_sets_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.businessName});

  final String businessName;

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                      Navigator.of(ctx).pop();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = LocaleController().currentLanguage;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
                      child: Text(
                        businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'B',
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
                            businessName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Store Admin · Active Session',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Language Selector Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                ),
                child: ListTile(
                  onTap: () => _showLanguagePicker(context),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language_rounded, color: AppColors.inkTeal, size: 20),
                  ),
                  title: Text(
                    context.tr('settings.language'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${currentLang.flagEmoji} ${currentLang.nativeName} (${currentLang.name})',
                    style: const TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
                ),
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: context.tr('settings.general'),
                items: [
                  _SettingsItem(
                    icon: Icons.storefront_outlined,
                    title: context.tr('settings.business_info'),
                    subtitle: 'Store location, category and contact info',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.receipt_long_outlined,
                    title: context.tr('settings.receipt_templates'),
                    subtitle: 'Header, footer logos & layouts',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.percent_outlined,
                    title: context.tr('settings.taxes_fees'),
                    subtitle: 'Configure VAT, service charges, discounts',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: context.tr('settings.team_locations'),
                items: [
                  _SettingsItem(
                    icon: Icons.storefront_outlined,
                    title: context.tr('settings.locations'),
                    subtitle: 'Manage store branches and addresses',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LocationsListView()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: context.tr('settings.permission_sets'),
                    subtitle: 'Define staff roles and access levels',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PermissionSetsListView()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSettingsGroup(
                context,
                title: context.tr('settings.hardware_sync'),
                items: [
                  _SettingsItem(
                    icon: Icons.print_outlined,
                    title: context.tr('settings.thermal_printers'),
                    subtitle: 'Bluetooth / LAN printer setups',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.barcode_reader,
                    title: context.tr('settings.barcode_scanners'),
                    subtitle: 'External hardware configurations',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.sync_outlined,
                    title: context.tr('settings.sync_cache'),
                    subtitle: 'Local backup status: All synced',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
                ),
                child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(context.tr('settings.logout_confirm_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        content: Text(context.tr('settings.logout_confirm_msg')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(context.tr('common.cancel'), style: const TextStyle(color: AppColors.slate)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(context.tr('settings.logout'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout, color: AppColors.error, size: 20),
                  ),
                  title: Text(
                    context.tr('settings.logout'),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
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
            border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                ListTile(
                  onTap: items[i].onTap,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(items[i].icon, color: AppColors.inkTeal, size: 20),
                  ),
                  title: Text(
                    items[i].title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    items[i].subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
                ),
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

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
