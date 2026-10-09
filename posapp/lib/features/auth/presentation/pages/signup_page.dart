import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/form_field_label.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../data/auth_repository.dart';
import '../../../Organisations/presentation/pages/select_business.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_wordmark.dart';
import '../widgets/auth_step_indicator.dart';
import '../widgets/otp_verification_view.dart';
import './login_page.dart';

/// Multi-step user registration flow.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

enum _Step { account, security, creating, verify }

class _SignupData {
  String fullname = '';
  String email = '';
  String phone = '';
  String password = '';
}

class _SignupPageState extends State<SignupPage> {
  _Step _step = _Step.account;
  int _direction = 1; // 1 = forward (slide in from right), -1 = backward
  String? _errorText;

  final _data = _SignupData();
  final _accountFormKey = GlobalKey<FormState>();
  final _securityFormKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  static const _stepOrder = [
    _Step.account,
    _Step.security,
    _Step.creating,
    _Step.verify,
  ];

  int get _indicatorIndex {
    final i = _stepOrder.indexOf(_step);
    return i >= 2 ? 2 : i; // creating and verify light up the last step dot
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
      case _Step.account:
        if (!_accountFormKey.currentState!.validate()) return;
        _data.fullname = _nameCtrl.text.trim();
        _data.email = _emailCtrl.text.trim();
        _data.phone = _phoneCtrl.text.trim();
        _goTo(_Step.security);
        break;

      case _Step.security:
        if (!_securityFormKey.currentState!.validate()) return;
        _data.password = _passwordCtrl.text;
        _goTo(_Step.creating);
        _registerUser();
        break;

      case _Step.creating:
        break; // no-op, waiting on _registerUser()

      case _Step.verify:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        break;
    }
  }

  Future<void> _registerUser() async {
    final authRepo = AuthRepository();
    final dto = RegisterDto(
      email: _data.email,
      password: _data.password,
      fullname: _data.fullname.isNotEmpty ? _data.fullname : null,
      phone: _data.phone.isNotEmpty ? _data.phone : null,
    );

    final response = await authRepo.register(dto);

    if (!mounted || _step != _Step.creating) return;

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        context.tr('auth.otp_desc', args: {'email': _data.email}),
      );
      _goTo(_Step.verify);
    } else {
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
      _goTo(_Step.security, direction: -1);
      setState(() {
        _errorText = response.errorMessage ?? context.tr('common.error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepLabels = [
      context.tr('auth.create_account'),
      context.tr('auth.password'),
      context.tr('auth.verify_email'),
    ];

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
                        color: AppColors.hairline.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthWordmark(),
                        const SizedBox(height: 24),
                        if (_step != _Step.creating && _step != _Step.verify) ...[
                          AuthStepIndicator(
                            currentIndex: _indicatorIndex,
                            labels: stepLabels,
                          ),
                          const SizedBox(height: 24),
                        ],
                        ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final isIncoming = child.key == ValueKey(_step);
                              final offsetAnim = Tween<Offset>(
                                begin: Offset(
                                  isIncoming ? _direction * 0.15 : -_direction * 0.15,
                                  0,
                                ),
                                end: Offset.zero,
                              ).animate(animation);
                              return ClipRect(
                                child: SlideTransition(
                                  position: offsetAnim,
                                  child: FadeTransition(opacity: animation, child: child),
                                ),
                              );
                            },
                            layoutBuilder: (currentChild, previousChildren) => Stack(
                              alignment: Alignment.topCenter,
                              children: [...previousChildren, ?currentChild],
                            ),
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _buildStepContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_step == _Step.account)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('auth.already_have_account'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.inkTeal,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: Text(context.tr('auth.login')),
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
      case _Step.account:
        return Form(
          key: _accountFormKey,
          child: _StepShell(
            title: context.tr('auth.create_account'),
            subtitle: context.tr('auth.sign_in_to_continue'),
            errorText: _errorText,
            onBack: _back,
            onContinue: _next,
            showBack: true,
            continueLabel: context.tr('common.continue'),
            fields: [
              AuthTextField(
                label: context.tr('auth.full_name'),
                hintText: context.tr('auth.full_name_hint'),
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                isRequired: false,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: context.tr('auth.email'),
                hintText: context.tr('auth.email_hint'),
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidators.email.validate,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              FormFieldLabel(
                label: context.tr('auth.phone'),
                isRequired: false,
              ),
              PhoneInputField(
                controller: _phoneCtrl,
                isRequired: false,
                hintText: context.tr('auth.phone_hint'),
              ),
            ],
          ),
        );

      case _Step.security:
        return Form(
          key: _securityFormKey,
          child: _StepShell(
            title: context.tr('auth.set_new_password_title'),
            subtitle: context.tr('auth.password_min_length'),
            errorText: _errorText,
            onBack: _back,
            onContinue: _next,
            continueLabel: context.tr('auth.create_account'),
            fields: [
              AuthTextField(
                label: context.tr('auth.password'),
                hintText: context.tr('auth.password_min_length'),
                obscureText: true,
                controller: _passwordCtrl,
                validator: AuthValidators.password.validate,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
              PasswordStrengthIndicator(
                password: _passwordCtrl.text,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: context.tr('auth.confirm_new_password'),
                hintText: context.tr('auth.password_hint'),
                obscureText: true,
                controller: _confirmCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != _passwordCtrl.text) {
                    return context.tr('auth.passwords_dont_match');
                  }
                  return null;
                },
                isRequired: true,
              ),
            ],
          ),
        );

      case _Step.creating:
        return const _CreatingAccountView();

      case _Step.verify:
        return _VerifyEmailView(
          email: _data.email,
          data: _data,
          onContinue: _next,
        );
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

class _CreatingAccountView extends StatelessWidget {
  const _CreatingAccountView();

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
          Text(context.tr('common.loading'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            context.tr('auth.sign_in_to_continue'),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView({
    required this.email,
    required this.data,
    required this.onContinue,
  });

  final String email;
  final _SignupData data;
  final VoidCallback onContinue;

  Future<void> _handleVerify(BuildContext context, String token) async {
    final authRepo = AuthRepository();
    final response = await authRepo.verifyOtp(
      VerifyOtpDto(email: email, token: token),
    );

    if (!context.mounted) return;

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(context, context.tr('auth.otp_verified'));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectBusinessPage()),
      );
    } else {
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
      final code = response.errorCode;
      final msg = response.errorMessage ?? context.tr('common.error');
      throw Exception(code != null && code.isNotEmpty ? '$code: $msg' : msg);
    }
  }

  Future<void> _handleResend(BuildContext context) async {
    final authRepo = AuthRepository();
    final dto = RegisterDto(
      email: data.email,
      password: data.password,
      fullname: data.fullname.isNotEmpty ? data.fullname : null,
      phone: data.phone.isNotEmpty ? data.phone : null,
    );

    final response = await authRepo.register(dto);

    if (!context.mounted) return;

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        context.tr('auth.otp_desc', args: {'email': email}),
      );
    } else {
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
      final code = response.errorCode;
      final msg = response.errorMessage ?? context.tr('common.error');
      throw Exception(code != null && code.isNotEmpty ? '$code: $msg' : msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OtpVerificationView(
      email: email,
      title: context.tr('auth.verify_email'),
      subtitle: context.tr('auth.otp_desc', args: {'email': email}),
      buttonLabel: context.tr('auth.verify_email'),
      onVerify: (token) => _handleVerify(context, token),
      onResend: () => _handleResend(context),
    );
  }
}