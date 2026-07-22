import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard.dart';
import '../../data/orgs_repository.dart';
import '../widgets/select_business_card.dart';

/// Shown right after sign in when a user has access to more than one business/branch.
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

  // Default fallback data if API returns empty list or mock setup
  static const _defaultLocations = [
    (name: 'Kohuwala Apparel', category: 'Apparel · Branch', icon: Icons.checkroom_outlined),
    (name: 'Grocery Store', category: 'Grocery', icon: Icons.local_grocery_store_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _orgsRepository.fetchOrganizations();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _organizations = response.data!;
      } else {
        _errorMessage = response.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select a business',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose which store you\'re working in today.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_organizations.isNotEmpty)
                    for (final org in _organizations) ...[
                      SelectBusinessCard(
                        name: org.name,
                        category: org.category ?? 'Branch',
                        icon: Icons.storefront_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DashboardPage(businessName: org.name),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ]
                  else ...[
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    for (final location in _defaultLocations) ...[
                      SelectBusinessCard(
                        name: location.name,
                        category: location.category,
                        icon: location.icon,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DashboardPage(businessName: location.name),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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