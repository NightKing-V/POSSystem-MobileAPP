import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/business_setup_controller.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedCategory = 'Coffee Shop / Cafe';
  String _selectedCurrency = 'USD (\$)';
  String _selectedLocation = 'United States';

  final List<String> _categories = [
    'Coffee Shop / Cafe',
    'Retail Boutique',
    'Supermarket / Grocery',
    'Fashion Apparel',
    'Electronics Store',
    'Restaurant / Food Service',
  ];

  final List<String> _currencies = [
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'INR (₹)',
    'JPY (¥)',
    'AED (د.إ)',
  ];

  final List<String> _locations = [
    'United States',
    'United Kingdom',
    'India',
    'Germany',
    'Japan',
    'United Arab Emirates',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveStep1(BusinessSetupController controller) {
    if (!_formKey.currentState!.validate()) return;

    controller.updateDetails(
      name: _nameController.text,
      category: _selectedCategory,
      currency: _selectedCurrency,
      location: _selectedLocation,
    );
    controller.nextStep();
  }

  Future<void> _handleFinish(BusinessSetupController controller) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await controller.completeOnboarding(authController);

    if (mounted) {
      if (success) {
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Onboarding failed.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BusinessSetupController>(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Onboarding Terminal',
          style: GoogleFonts.inter(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.outline),
            onPressed: () {
              Provider.of<AuthController>(context, listen: false).logout();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 16),
            child: _StepIndicator(currentStep: controller.currentStep),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 20 : 40),
                child: _buildWizardStep(controller, isCompact),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWizardStep(BusinessSetupController controller, bool isCompact) {
    switch (controller.currentStep) {
      case 0:
        return _buildStep1Profile(controller);
      case 1:
        return _buildStep2Subscription(controller, isCompact);
      case 2:
        return _buildStep3Review(controller);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── STEP 1: BUSINESS PROFILE ──────────────────────────────────────────────
  Widget _buildStep1Profile(BusinessSetupController controller) {
    if (_nameController.text.isEmpty && controller.businessName.isNotEmpty) {
      _nameController.text = controller.businessName;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Business Profile',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide details to establish your multi-tenant operations node.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Business Name
          Text(
            'BUSINESS REGISTER NAME',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'e.g. Coffee & Co. Roasters',
              prefixIcon: Icon(Icons.storefront_outlined, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your business register name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Category & Currency Row
          LayoutBuilder(
            builder: (context, constraints) {
              final useVertical = constraints.maxWidth < 500;
              return Flex(
                direction: useVertical ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: useVertical ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BUSINESS CATEGORY',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val!),
                        ),
                      ],
                    ),
                  ),
                  if (!useVertical) const SizedBox(width: 24),
                  if (useVertical) const SizedBox(height: 20),
                  Expanded(
                    flex: useVertical ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BASE CURRENCY',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: _currencies
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCurrency = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Location Selection
          Text(
            'MAIN OFFICE LOCATION',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
            ),
            items: _locations
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (val) => setState(() => _selectedLocation = val!),
          ),
          const SizedBox(height: 40),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveStep1(controller),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('CONTINUE TO BILLING'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: SUBSCRIPTION SELECTION ────────────────────────────────────────
  Widget _buildStep2Subscription(
    BusinessSetupController controller,
    bool isCompact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Subscription Tier',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a monthly SaaS plan to power your store registers. You can change plans at any time.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // Plans layout
        if (isCompact)
          Column(
            children: [
              _PlanCard(
                tierName: 'Starter',
                price: '\$19',
                details:
                    '1 active terminal\n3 staff profiles\nStandard sales analytics',
                isSelected: controller.selectedPlan == 'Starter',
                onSelect: () => controller.setPlan('Starter'),
                recommended: false,
              ),
              const SizedBox(height: 16),
              _PlanCard(
                tierName: 'Pro',
                price: '\$49',
                details:
                    'Unlimited active terminals\nCustom manager/cashier roles\nReal-time cloud database',
                isSelected: controller.selectedPlan == 'Pro',
                onSelect: () => controller.setPlan('Pro'),
                recommended: true,
              ),
              const SizedBox(height: 16),
              _PlanCard(
                tierName: 'Enterprise',
                price: '\$129',
                details:
                    'Multi-location inventory\nMainframe API endpoints\nDedicated 24/7 account support',
                isSelected: controller.selectedPlan == 'Enterprise',
                onSelect: () => controller.setPlan('Enterprise'),
                recommended: false,
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PlanCard(
                  tierName: 'Starter',
                  price: '\$19',
                  details:
                      '1 active terminal\n3 staff profiles\nStandard analytics',
                  isSelected: controller.selectedPlan == 'Starter',
                  onSelect: () => controller.setPlan('Starter'),
                  recommended: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PlanCard(
                  tierName: 'Pro',
                  price: '\$49',
                  details:
                      'Unlimited terminals\nCustom cashier roles\nReal-time cloud sync',
                  isSelected: controller.selectedPlan == 'Pro',
                  onSelect: () => controller.setPlan('Pro'),
                  recommended: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PlanCard(
                  tierName: 'Enterprise',
                  price: '\$129',
                  details:
                      'Multi-location stock\nAPI endpoint access\n24/7 dedicated assistance',
                  isSelected: controller.selectedPlan == 'Enterprise',
                  onSelect: () => controller.setPlan('Enterprise'),
                  recommended: false,
                ),
              ),
            ],
          ),

        const SizedBox(height: 40),

        // Navigation Actions
        Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: controller.previousStep,
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.nextStep,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('REVIEW SUMMARY'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── STEP 3: REVIEW & LAUNCH ───────────────────────────────────────────────
  Widget _buildStep3Review(BusinessSetupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Setup & Launch',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your subscription configurations before firing your active POS node.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),

        // Configuration Summary Box
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.accentGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Multi-Tenant Setup Confirmed',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ReviewRow(
                label: 'BUSINESS NAME',
                value: controller.businessName,
              ),
              const Divider(height: 24, color: AppColors.outlineVariant),
              _ReviewRow(label: 'CATEGORY', value: controller.businessCategory),
              const Divider(height: 24, color: AppColors.outlineVariant),
              _ReviewRow(
                label: 'OPERATIONAL OFFICE',
                value: controller.location,
              ),
              const Divider(height: 24, color: AppColors.outlineVariant),
              _ReviewRow(label: 'BASE CURRENCY', value: controller.currency),
              const Divider(height: 24, color: AppColors.outlineVariant),
              _ReviewRow(
                label: 'SELECTED SUBSCRIPTION TIER',
                value: '${controller.selectedPlan} Plan',
                highlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Billing notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.card_membership,
                color: AppColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '14-day free trial active. Your first payment occurs June 2026.',
                  style: GoogleFonts.inter(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Navigation Actions
        Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: controller.previousStep,
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () => _handleFinish(controller),
                child: controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch, size: 18),
                          SizedBox(width: 8),
                          Text('LAUNCH BUSINESS'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── HELPERS & SUB-WIDGETS ───────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepCircle(
          stepNum: 1,
          label: 'Profile',
          isActive: currentStep >= 0,
          isCompleted: currentStep > 0,
        ),
        _StepDivider(isCompleted: currentStep > 0),
        _StepCircle(
          stepNum: 2,
          label: 'Subscription',
          isActive: currentStep >= 1,
          isCompleted: currentStep > 1,
        ),
        _StepDivider(isCompleted: currentStep > 1),
        _StepCircle(
          stepNum: 3,
          label: 'Launch',
          isActive: currentStep >= 2,
          isCompleted: false,
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNum,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final int stepNum;
  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.accentGreen
                : (isActive ? AppColors.secondary : Colors.transparent),
            border: Border.all(
              color: isCompleted
                  ? AppColors.accentGreen
                  : (isActive ? AppColors.secondary : AppColors.outlineVariant),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$stepNum',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.outline,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.outline,
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider({required this.isCompleted});
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: isCompleted ? AppColors.accentGreen : AppColors.outlineVariant,
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.tierName,
    required this.price,
    required this.details,
    required this.isSelected,
    required this.onSelect,
    required this.recommended,
  });

  final String tierName;
  final String price;
  final String details;
  final bool isSelected;
  final VoidCallback onSelect;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (recommended
                      ? AppColors.secondary.withOpacity(0.3)
                      : AppColors.outlineVariant),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tierName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                if (recommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '/mo',
                  style: GoogleFonts.inter(
                    color: AppColors.outline,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.outlineVariant),
            Text(
              details,
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.secondary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: highlight ? AppColors.secondary : AppColors.primary,
          ),
        ),
      ],
    );
  }
}
