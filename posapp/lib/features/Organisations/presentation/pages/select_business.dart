import 'package:flutter/material.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/permissions/permissions_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../dashboard/presentation/pages/dashboard.dart';
import '../../../settings/presentation/widgets/settings_dialogs.dart';
import '../../data/orgs_repository.dart';
import '../widgets/create_business_form.dart';
import '../widgets/select_business_card.dart';

/// Shown right after sign in when a user has access to one or more businesses/branches,
/// or prompts the user inline to create a new one if none exist.
class SelectBusinessPage extends StatefulWidget {
  const SelectBusinessPage({super.key});

  @override
  State<SelectBusinessPage> createState() => _SelectBusinessPageState();
}

class _SelectBusinessPageState extends State<SelectBusinessPage> {
  final OrgsRepository _orgsRepository = OrgsRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<Organization> _organizations = [];
  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    // Check if token exists before making network calls
    if (!TokenStorage.isAuthenticated) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _orgsRepository.fetchOrganizations();

    if (!mounted) return;

    // If unauthorized or token invalid, redirect immediately to login
    if (response.statusCode == 401 || !TokenStorage.isAuthenticated) {
      await TokenStorage.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _organizations = response.data ?? [];
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? context.tr('common.error');
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await SettingsDialogs.confirmLogout(context);
    if (!confirmed || !mounted) return;

    await TokenStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCreateForm = !_isLoading && _errorMessage == null && (_organizations.isEmpty || _isAddingNew);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dynamic Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _errorMessage != null
                                  ? context.tr('common.error')
                                  : (_organizations.isEmpty
                                      ? context.tr('orgs.create_business_get_started')
                                      : (_isAddingNew
                                          ? context.tr('orgs.create_new_business')
                                          : context.tr('orgs.select_business'))),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage != null
                                  ? context.tr('common.no_data')
                                  : (_organizations.isEmpty
                                      ? context.tr('orgs.set_up_store_details')
                                      : (_isAddingNew
                                          ? context.tr('orgs.add_another_branch')
                                          : context.tr('orgs.choose_store'))),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppColors.slate,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLoading && _organizations.isNotEmpty && !_isAddingNew && _errorMessage == null)
                            IconButton(
                              tooltip: context.tr('common.refresh'),
                              icon: const Icon(Icons.refresh_rounded, color: AppColors.slate),
                              onPressed: _loadOrganizations,
                            ),
                          IconButton(
                            tooltip: context.tr('settings.logout'),
                            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                            onPressed: _handleLogout,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Body Content
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage != null && _organizations.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.hairline.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.ink,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _loadOrganizations,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: Text(context.tr('common.retry')),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _handleLogout,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                                child: Text(context.tr('settings.logout')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else if (showCreateForm)
                    CreateBusinessForm(
                      onSuccess: () {
                        setState(() => _isAddingNew = false);
                        _loadOrganizations();
                      },
                      onCancel: _organizations.isNotEmpty
                          ? () => setState(() => _isAddingNew = false)
                          : null,
                      submitButtonText: _organizations.isEmpty
                          ? context.tr('orgs.create_and_start')
                          : context.tr('orgs.create_button'),
                    )
                  else ...[
                    // List of existing businesses
                    for (final org in _organizations) ...[
                      SelectBusinessCard(
                        name: org.name,
                        category: org.category ?? 'Branch',
                        icon: Icons.storefront_outlined,
                        onTap: () {
                          TokenStorage.setCurrentOrgId(org.id);
                          // Fetch and cache user permissions for the selected organization
                          PermissionsService().fetchAndCachePermissions(org.id);
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => DashboardPage(
                                    businessName: org.name,
                                    orgId: org.id,
                                    locationId: org.primaryLocation?.id,
                                  ),
                                ),
                              )
                              .then((_) {
                                if (mounted) _loadOrganizations();
                              });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 12),
                    // Action button to switch into create mode inline
                    InkWell(
                      onTap: () => setState(() => _isAddingNew = true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.inkTeal.withValues(alpha: 0.3),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_business_rounded, color: AppColors.inkTeal, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              context.tr('orgs.create_new_business'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppColors.inkTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
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