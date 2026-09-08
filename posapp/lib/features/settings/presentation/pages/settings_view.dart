import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../Organisations/data/orgs_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../staff/presentation/pages/permission_sets_list_view.dart';
import '../widgets/business_header_card.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/settings_dialogs.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/settings_tile_item.dart';
import './locations_list_view.dart';

/// Clean Settings View orchestrating modular settings group cards,
/// profile header, language modal, and danger actions.
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.businessName,
    this.orgId,
  });

  final String businessName;
  final String? orgId;

  Future<void> _handleDeleteBusiness(BuildContext context) async {
    if (!TokenStorage.isAuthenticated) {
      ApiHelper.showErrorSnackBar(
        context,
        'Session expired or missing authentication token. Please sign in again.',
      );
      return;
    }

    if (orgId == null || orgId!.isEmpty) {
      ApiHelper.showErrorSnackBar(
        context,
        'Cannot delete: Business ID is missing.',
      );
      return;
    }

    final confirmed = await SettingsDialogs.confirmDeleteBusiness(
      context,
      businessName: businessName,
    );
    if (!confirmed || !context.mounted) return;

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.inkTeal),
      ),
    );

    final orgsRepo = OrgsRepository();
    final res = await orgsRepo.deleteOrganization(orgId!);

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        'Business "$businessName" deleted successfully.',
      );
      Navigator.of(context).pop();
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? 'Failed to delete business. Please try again.',
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await SettingsDialogs.confirmLogout(context);
    if (!confirmed || !context.mounted) return;

    final authRepo = AuthRepository();
    await authRepo.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
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
              // Store Header Card
              BusinessHeaderCard(businessName: businessName),
              const SizedBox(height: 20),

              // Language Selector Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hairline.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () => LanguagePickerSheet.show(context),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.inkTeal,
                      size: 20,
                    ),
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

              // General Settings
              SettingsGroupCard(
                title: context.tr('settings.general'),
                items: [
                  SettingsTileItem(
                    icon: Icons.storefront_outlined,
                    title: context.tr('settings.business_info'),
                    subtitle: 'Store location, category and contact info',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.receipt_long_outlined,
                    title: context.tr('settings.receipt_templates'),
                    subtitle: 'Header, footer logos & layouts',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.percent_outlined,
                    title: context.tr('settings.taxes_fees'),
                    subtitle: 'Configure VAT, service charges, discounts',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Team & Locations
              SettingsGroupCard(
                title: context.tr('settings.team_locations'),
                items: [
                  SettingsTileItem(
                    icon: Icons.storefront_outlined,
                    title: context.tr('settings.locations'),
                    subtitle: 'Manage store branches and addresses',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LocationsListView(),
                      ),
                    ),
                  ),
                  SettingsTileItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: context.tr('settings.permission_sets'),
                    subtitle: 'Define staff roles and access levels',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PermissionSetsListView(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hardware & Sync
              SettingsGroupCard(
                title: context.tr('settings.hardware_sync'),
                items: [
                  SettingsTileItem(
                    icon: Icons.print_outlined,
                    title: context.tr('settings.thermal_printers'),
                    subtitle: 'Bluetooth / LAN printer setups',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.barcode_reader,
                    title: context.tr('settings.barcode_scanners'),
                    subtitle: 'External hardware configurations',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.sync_outlined,
                    title: context.tr('settings.sync_cache'),
                    subtitle: 'Local backup status: All synced',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Danger Zone
              SettingsGroupCard(
                title: context.tr('settings.danger_zone'),
                items: [
                  SettingsTileItem(
                    icon: Icons.delete_forever_rounded,
                    title: context.tr('settings.delete_business'),
                    subtitle: context.tr('settings.delete_business_desc'),
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () => _handleDeleteBusiness(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Logout Action Tile
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hairline.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () => _handleLogout(context),
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
}
