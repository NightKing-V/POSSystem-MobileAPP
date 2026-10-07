import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/create_business_form.dart';

/// Standalone route for creating a business (used when navigated to directly with a back button)
class CreateBusinessPage extends StatelessWidget {
  const CreateBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          context.tr('orgs.create_new_business'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: CreateBusinessForm(
                onSuccess: () => Navigator.of(context).pop(true),
                onCancel: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
