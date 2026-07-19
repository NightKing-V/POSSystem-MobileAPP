import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard.dart';
import '../widgets/select_business_card.dart';
/// Shown right after sign in when a user has access to more than one
/// business/branch (backed by your `user_locations` table). UI only —
/// tapping a card pushes a placeholder screen; swap that for your
/// actual dashboard/shell once it exists.
class SelectBusinessPage extends StatelessWidget {
  const SelectBusinessPage({super.key});

  // Placeholder data — replace with the locations returned for the
  // signed-in user once auth + API wiring is in place.
  static const _locations = [
    (name: 'Kohuwala Apparel', category: 'Apparel · Branch', icon: Icons.checkroom_outlined),
    (name: 'Grocery Store', category: 'Grocery', icon: Icons.local_grocery_store_outlined),
  ];

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
                  for (final location in _locations) ...[
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}