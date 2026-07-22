import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../select_business/presentation/pages/select_business.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

/// Sign up screen wired to AuthRepository.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

enum _Step { credentials, phone, businessType, businessName, creating, verify }

class _SignupData {
  String email = '';
  String password = '';
  String phone = '';
  String? businessType;
  String businessName = '';
}

class _SignupPageState extends State<SignupPage> {
  _Step _step = _Step.credentials;
  int _direction = 1; // 1 = forward (slide in from right), -1 = backward
  String? _errorText;

  final _data = _SignupData();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();

  static const _stepOrder = [
    _Step.credentials,
    _Step.phone,
    _Step.businessType,
    _Step.businessName,
    _Step.creating,
    _Step.verify,
  ];

  static const _stepLabels = ['Account', 'Phone', 'Business', 'Details', 'Verify'];

  int get _indicatorIndex {
    final i = _stepOrder.indexOf(_step);
    return i >= 4 ? 4 : i; // creating + verify both light up the last dot
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    _businessNameCtrl.dispose();
    super.dispose();
  }

  void _goTo(_Step step, {int direction = 1}) {
    setState(() {
      _errorText = null;
      _direction = direction;
      _step = step;
    });
  }

  void _back() {
    final i = _stepOrder.indexOf(_step);
    if (i <= 0) {
      Navigator.of(context).pop();
      return;
    }
    _goTo(_stepOrder[i - 1], direction: -1);
  }

  void _next() {
    switch (_step) {
      case _Step.credentials:
        if (!_emailCtrl.text.contains('@') || _emailCtrl.text.trim().isEmpty) {
          setState(() => _errorText = 'Enter a valid email address');
          return;
        }
        if (_passwordCtrl.text.length < 6) {
          setState(() => _errorText = 'Password must be at least 6 characters');
          return;
        }
        if (_passwordCtrl.text != _confirmCtrl.text) {
          setState(() => _errorText = 'Passwords do not match');
          return;
        }
        _data.email = _emailCtrl.text.trim();
        _data.password = _passwordCtrl.text;
        _goTo(_Step.phone);
        break;

      case _Step.phone:
        if (_phoneCtrl.text.trim().length < 9) {
          setState(() => _errorText = 'Enter a valid phone number');
          return;
        }
        _data.phone = _phoneCtrl.text.trim();
        _goTo(_Step.businessType);
        break;

      case _Step.businessType:
        if (_data.businessType == null) {
          setState(() => _errorText = 'Choose a business type');
          return;
        }
        _goTo(_Step.businessName);
        break;

      case _Step.businessName:
        if (_businessNameCtrl.text.trim().isEmpty) {
          setState(() => _errorText = 'Enter your business name');
          return;
        }
        _data.businessName = _businessNameCtrl.text.trim();
        _goTo(_Step.creating);
        _createBusiness();
        break;

      case _Step.creating:
        break; // no-op, waiting on _createBusiness()

      case _Step.verify:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        break;
    }
  }

  Future<void> _createBusiness() async {
    // Placeholder for the real account/business creation call.
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted || _step != _Step.creating) return;
    _goTo(_Step.verify);
  }

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final businessName = _businessNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await _authRepository.register(
      email: email,
      password: password,
      businessName: businessName.isNotEmpty ? businessName : null,
      phone: phone.isNotEmpty ? phone : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectBusinessPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage ?? 'Sign up failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.hairline.withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Wordmark(),
                        const SizedBox(height: 20),
                        Text(
                          'Create account',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'to start tracking sales',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        const AuthTextField(
                          label: 'Business name',
                          hintText: 'e.g. Maya Boutique',
                        ),
                        const SizedBox(height: 20),
                        const AuthTextField(
                          label: 'Email',
                          hintText: 'you@business.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        const AuthTextField(
                          label: 'Phone',
                          hintText: '07X XXX XXXX',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        const AuthTextField(
                          label: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        const AuthTextField(
                          label: 'Confirm password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Create account',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.inkTeal,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _Step.credentials:
        return _StepShell(
          title: 'Create your account',
          subtitle: 'to start tracking sales',
          errorText: _errorText,
          onBack: _back,
          onContinue: _next,
          showBack: true,
          fields: [
            AuthTextField(label: 'Email', hintText: 'you@business.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            AuthTextField(label: 'Password', obscureText: true, controller: _passwordCtrl),
            const SizedBox(height: 20),
            AuthTextField(label: 'Confirm password', obscureText: true, controller: _confirmCtrl),
          ],
        );

      case _Step.phone:
        return _StepShell(
          title: 'What\'s your phone number?',
          subtitle: 'We\'ll use this for account recovery and receipts',
          errorText: _errorText,
          onBack: _back,
          onContinue: _next,
          fields: [
            AuthTextField(label: 'Phone', hintText: '07X XXX XXXX', controller: _phoneCtrl, keyboardType: TextInputType.phone),
          ],
        );

      case _Step.businessType:
        return _StepShell(
          title: 'What kind of business is it?',
          subtitle: 'This helps us tailor KIVI to how you sell',
          errorText: _errorText,
          onBack: _back,
          onContinue: _next,
          fields: [
            _BusinessTypeSelector(
              selected: _data.businessType,
              onSelected: (v) => setState(() {
                _data.businessType = v;
                _errorText = null;
              }),
            ),
          ],
        );

      case _Step.businessName:
        return _StepShell(
          title: 'Name your business',
          subtitle: 'This is what appears on receipts and reports',
          errorText: _errorText,
          onBack: _back,
          onContinue: _next,
          continueLabel: 'Create account',
          fields: [
            AuthTextField(label: 'Business name', hintText: 'e.g. Maya Boutique', controller: _businessNameCtrl),
          ],
        );

      case _Step.creating:
        return const _CreatingBusinessView();

      case _Step.verify:
        return _VerifyEmailView(email: _data.email, onContinue: _next);
    }
  }
}

/// Shared shell for the text-input style steps: title, subtitle, fields,
/// optional inline error, and a back/continue row.
class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onContinue,
    required this.onBack,
    this.errorText,
    this.continueLabel = 'Continue',
    this.showBack = true,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final String? errorText;
  final String continueLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.slate),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 28),
        ...fields,
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(errorText!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              continueLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusinessTypeOption {
  const _BusinessTypeOption(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

const _businessTypeOptions = [
  _BusinessTypeOption('retail', 'Retail store', Icons.storefront_outlined),
  _BusinessTypeOption('restaurant', 'Restaurant / cafe', Icons.restaurant_outlined),
  _BusinessTypeOption('service', 'Service business', Icons.handyman_outlined),
  _BusinessTypeOption('other', 'Other', Icons.apps_outlined),
];

class _BusinessTypeSelector extends StatelessWidget {
  const _BusinessTypeSelector({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in _businessTypeOptions) ...[
          _BusinessTypeCard(
            option: option,
            selected: option.id == selected,
            onTap: () => onSelected(option.id),
          ),
          if (option != _businessTypeOptions.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BusinessTypeCard extends StatelessWidget {
  const _BusinessTypeCard({required this.option, required this.selected, required this.onTap});

  final _BusinessTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkTeal.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.inkTeal : AppColors.hairline,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon, size: 20, color: selected ? AppColors.inkTeal : AppColors.slate),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: selected ? 1 : 0,
              child: const Icon(Icons.check_circle, size: 20, color: AppColors.inkTeal),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatingBusinessView extends StatelessWidget {
  const _CreatingBusinessView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.inkTeal),
          ),
          const SizedBox(height: 20),
          Text('Setting up your business…', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'This only takes a moment',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView({required this.email, required this.onContinue});

  final String email;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.marigold.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.inkTeal, size: 26),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Verify your email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a verification link to\n$email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "I've verified — continue",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email resent')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.inkTeal),
            child: const Text('Resend email', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

/// Thin step indicator: filled/labeled bars, like the progress rail on
/// Google's account-creation flow. Purely presentational.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.inkTeal : AppColors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i != labels.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Center(child: Image.asset('assets/logo.png', height: 64));
  }
}