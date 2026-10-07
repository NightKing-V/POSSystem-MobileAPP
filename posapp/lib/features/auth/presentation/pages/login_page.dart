import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../Organisations/presentation/pages/select_business.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import './forgot_password_page.dart';
import './signup_page.dart';
import '../../data/auth_repository.dart';
import '../../../../core/api/api_helper.dart';

import '../widgets/auth_wordmark.dart';

/// Login screen connected to Auth API.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorText = context.tr('auth.invalid_email'));
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorText = context.tr('auth.password_min_length'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final response = await _authRepo.login(email: email, password: password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(context, context.tr('common.success'));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectBusinessPage()),
      );
    } else {
      setState(() {
        _errorText = response.errorMessage ?? context.tr('common.error');
      });
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
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
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
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
                      children: [
                        const AuthWordmark(),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('auth.login'),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('auth.sign_in_to_continue'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          label: context.tr('auth.email'),
                          hintText: context.tr('auth.email_hint'),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          label: context.tr('auth.password'),
                          obscureText: true,
                          controller: _passwordCtrl,
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordPage(
                                    initialEmail: _emailCtrl.text.trim(),
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.inkTeal,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              context.tr('auth.forgot_password'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.tr('auth.login'),
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
                      Text(context.tr('auth.dont_have_account'), style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.inkTeal,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: Text(context.tr('auth.signup')),
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
}