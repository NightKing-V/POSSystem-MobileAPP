import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/management_header.dart';
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

enum SettingsSubPage {
  locations,
  permissionSets,
  businessInfo,
  receiptTemplates,
  taxesFees,
  thermalPrinters,
  barcodeScanners,
  syncCache,
}

/// Settings View orchestrating modular settings group cards,
/// seamless inlay subpage navigation with back button, profile header,
/// language modal, and danger actions.
class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.businessName,
    this.orgId,
  });

  final String businessName;
  final String? orgId;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsSubPage? _currentSubPage;

  Future<void> _handleDeleteBusiness(BuildContext context) async {
    if (!TokenStorage.isAuthenticated) {
      ApiHelper.showErrorSnackBar(
        context,
        'Session expired or missing authentication token. Please sign in again.',
      );
      return;
    }

    if (widget.orgId == null || widget.orgId!.isEmpty) {
      ApiHelper.showErrorSnackBar(
        context,
        'Cannot delete: Business ID is missing.',
      );
      return;
    }

    final confirmed = await SettingsDialogs.confirmDeleteBusiness(
      context,
      businessName: widget.businessName,
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
    final res = await orgsRepo.deleteOrganization(widget.orgId!);

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        'Business "${widget.businessName}" deleted successfully.',
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

  Widget _buildGenericSettingsSubpage({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ManagementHeaderBar(
              title: title,
              subtitle: subtitle,
              hideMobileTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                tooltip: context.tr('settings.back_to_settings'),
                onPressed: () => setState(() => _currentSubPage = null),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.hairline.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.inkTeal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: AppColors.inkTeal, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      subtitle,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.hairline, height: 1),
                          const SizedBox(height: 20),
                          ...children,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSubPage != null) {
      Widget subPageWidget;
      switch (_currentSubPage!) {
        case SettingsSubPage.locations:
          subPageWidget = LocationsListView(
            isEmbedded: true,
            onBack: () => setState(() => _currentSubPage = null),
          );
          break;
        case SettingsSubPage.permissionSets:
          subPageWidget = PermissionSetsListView(
            orgId: widget.orgId,
            isEmbedded: true,
            onBack: () => setState(() => _currentSubPage = null),
          );
          break;
        case SettingsSubPage.businessInfo:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.business_info'),
            subtitle: context.tr('settings.store_location_category_desc'),
            icon: Icons.storefront_outlined,
            children: [
              _InfoRow(label: context.tr('settings.store_name'), value: widget.businessName),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.organization_id'), value: widget.orgId ?? context.tr('settings.default_tenant')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.category_label'), value: context.tr('settings.retail_store')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.status_label'), value: context.tr('settings.active_tenant')),
            ],
          );
          break;
        case SettingsSubPage.receiptTemplates:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.receipt_templates'),
            subtitle: context.tr('settings.receipt_templates_desc'),
            icon: Icons.receipt_long_outlined,
            children: [
              _InfoRow(label: context.tr('settings.header_text'), value: context.tr('settings.header_text_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.paper_size'), value: context.tr('settings.paper_size_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.footer_note'), value: context.tr('settings.footer_note_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.show_barcode'), value: context.tr('settings.enabled')),
            ],
          );
          break;
        case SettingsSubPage.taxesFees:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.taxes_fees'),
            subtitle: context.tr('settings.taxes_fees_desc'),
            icon: Icons.percent_outlined,
            children: [
              _InfoRow(label: context.tr('settings.vat_sales_tax'), value: context.tr('settings.vat_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.service_charge'), value: '0%'),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.cash_discounting'), value: context.tr('settings.supported')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.rounding_mode'), value: context.tr('settings.rounding_val')),
            ],
          );
          break;
        case SettingsSubPage.thermalPrinters:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.thermal_printers'),
            subtitle: context.tr('settings.thermal_printers_desc'),
            icon: Icons.print_outlined,
            children: [
              _InfoRow(label: context.tr('settings.default_printer'), value: context.tr('settings.default_printer_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.printer_interface'), value: context.tr('settings.printer_interface_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.auto_cut_paper'), value: context.tr('settings.enabled')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.cash_drawer_kick'), value: context.tr('settings.cash_drawer_val')),
            ],
          );
          break;
        case SettingsSubPage.barcodeScanners:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.barcode_scanners'),
            subtitle: context.tr('settings.barcode_scanners_desc'),
            icon: Icons.barcode_reader,
            children: [
              _InfoRow(label: context.tr('settings.scanner_mode'), value: context.tr('settings.scanner_mode_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.suffix_key'), value: context.tr('settings.suffix_key_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.camera_scanner'), value: context.tr('settings.camera_scanner_val')),
            ],
          );
          break;
        case SettingsSubPage.syncCache:
          subPageWidget = _buildGenericSettingsSubpage(
            title: context.tr('settings.sync_cache'),
            subtitle: context.tr('settings.sync_cache_desc'),
            icon: Icons.sync_outlined,
            children: [
              _InfoRow(label: context.tr('settings.sync_status'), value: context.tr('settings.sync_status_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.offline_storage'), value: context.tr('settings.offline_storage_val')),
              const SizedBox(height: 12),
              _InfoRow(label: context.tr('settings.pending_uploads'), value: context.tr('settings.pending_uploads_val')),
            ],
          );
          break;
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          setState(() => _currentSubPage = null);
        },
        child: subPageWidget,
      );
    }

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
              BusinessHeaderCard(businessName: widget.businessName),
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
                    subtitle: context.tr('settings.store_location_category_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.businessInfo),
                  ),
                  SettingsTileItem(
                    icon: Icons.receipt_long_outlined,
                    title: context.tr('settings.receipt_templates'),
                    subtitle: context.tr('settings.receipt_templates_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.receiptTemplates),
                  ),
                  SettingsTileItem(
                    icon: Icons.percent_outlined,
                    title: context.tr('settings.taxes_fees'),
                    subtitle: context.tr('settings.taxes_fees_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.taxesFees),
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
                    subtitle: context.tr('settings.locations_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.locations),
                  ),
                  SettingsTileItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: context.tr('settings.permission_sets'),
                    subtitle: context.tr('settings.permission_sets_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.permissionSets),
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
                    subtitle: context.tr('settings.thermal_printers_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.thermalPrinters),
                  ),
                  SettingsTileItem(
                    icon: Icons.barcode_reader,
                    title: context.tr('settings.barcode_scanners'),
                    subtitle: context.tr('settings.barcode_scanners_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.barcodeScanners),
                  ),
                  SettingsTileItem(
                    icon: Icons.sync_outlined,
                    title: context.tr('settings.sync_cache'),
                    subtitle: context.tr('settings.sync_cache_desc'),
                    onTap: () => setState(() => _currentSubPage = SettingsSubPage.syncCache),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
