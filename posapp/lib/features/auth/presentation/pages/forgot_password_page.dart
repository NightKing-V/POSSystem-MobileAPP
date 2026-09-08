import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_wordmark.dart';
import '../widgets/auth_step_indicator.dart';
import '../widgets/otp_verification_view.dart';
import './login_page.dart';

/// Single-route multi-step Password Reset flow (matching SignupPage):
/// Step 1: Enter email to request OTP
/// Step 2: Verify OTP via reusable OtpVerificationView and obtain access token
/// Step 3: Set and confirm new password
/// Step 4: Success confirmation screen
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum _ResetStep { email, otp, newPassword, success }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  _ResetStep _step = _ResetStep.email;
  int _direction = 1; // 1 = forward (slide in from right), -1 = backward
  bool _isLoading = false;
  String? _errorText;
  String _otpToken = '';

  final _authRepo = AuthRepository();
  late final TextEditingController _emailCtrl;
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  static const _stepLabels = ['Email', 'Verify OTP', 'New Password'];

  int get _indicatorIndex {
    switch (_step) {
      case _ResetStep.email:
        return 0;
      case _ResetStep.otp:
        return 1;
      case _ResetStep.newPassword:
      case _ResetStep.success:
        return 2;
    }
  }

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _goTo(_ResetStep step, {int direction = 1}) {
    setState(() {
      _errorText = null;
      _direction = direction;
      _step = step;
    });
  }

  void _back() {
    switch (_step) {
      case _ResetStep.email:
        Navigator.of(context).pop();
        break;
      case _ResetStep.otp:
        _goTo(_ResetStep.email, direction: -1);
        break;
      case _ResetStep.newPassword:
        _goTo(_ResetStep.otp, direction: -1);
        break;
      case _ResetStep.success:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        break;
    }
  }

  /// Step 1: Request OTP by Email
  Future<void> _handleRequestOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorText = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final response = await _authRepo.forgotPassword(
      ForgotPasswordDto(email: email),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        'Verification code sent to $email',
      );
      _goTo(_ResetStep.otp);
    } else {
      setState(() {
        _errorText =
            response.errorMessage ??
            'Failed to send OTP code. Please try again.';
      });
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
    }
  }

  /// Step 2: Verify OTP via API and obtain access token
  Future<void> _handleVerifyOtp(String token) async {
    final email = _emailCtrl.text.trim();
    final response = await _authRepo.verifyOtp(
      VerifyOtpDto(email: email, token: token, type: 'recovery'),
    );

    if (!mounted) return;

    if (response.isSuccess) {
      final acquiredToken =
          response.data?['accessToken'] as String? ??
          response.data?['session']?['access_token'] as String? ??
          token;
      _otpToken = acquiredToken;
      ApiHelper.showSuccessSnackBar(context, 'Code verified successfully!');
      _goTo(_ResetStep.newPassword);
    } else {
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
      throw Exception(
        response.errorMessage ??
            'Invalid OTP code. Please check and try again.',
      );
    }
  }

  /// Resend OTP
  Future<void> _handleResendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    final response = await _authRepo.forgotPassword(
      ForgotPasswordDto(email: email),
    );

    if (!mounted) return;

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(context, 'OTP resent to $email');
    } else {
      ApiHelper.showErrorSnackBar(context, response.errorMessage);
    }
  }

  /// Step 3: Set New Password
  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (newPassword.length < 8) {
      setState(() {
        _errorText = context.tr('auth.password_min_length');
        if (_errorText == 'auth.password_min_length') {
          _errorText = 'Password must be at least 8 characters long.';
        }
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorText = context.tr('auth.passwords_dont_match');
        if (_errorText == 'auth.passwords_dont_match') {
          _errorText = 'Passwords do not match.';
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final response = await _authRepo.resetPassword(
      ResetPasswordDto(newPassword: newPassword, accessToken: _otpToken),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(context, 'Password reset successfully!');
      _goTo(_ResetStep.success);
    } else {
      setState(() {
        _errorText =
            response.errorMessage ??
            'Failed to reset password. Please try again.';
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
                        const SizedBox(height: 20),
                        if (_step != _ResetStep.success) ...[
                          AuthStepIndicator(
                            currentIndex: _indicatorIndex,
                            labels: _stepLabels,
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
                                  isIncoming
                                      ? _direction * 0.15
                                      : -_direction * 0.15,
                                  0,
                                ),
                                end: Offset.zero,
                              ).animate(animation);
                              return ClipRect(
                                child: SlideTransition(
                                  position: offsetAnim,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            layoutBuilder: (currentChild, previousChildren) =>
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
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
                  if (_step != _ResetStep.success)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Remembered your password? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.inkTeal,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
      case _ResetStep.email:
        return _buildEmailStep();
      case _ResetStep.otp:
        return _buildOtpStep();
      case _ResetStep.newPassword:
        return _buildNewPasswordStep();
      case _ResetStep.success:
        return _buildSuccessStep();
    }
  }

  /// Step 1: Email Form
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _back,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.tr('auth.reset_password_title'),
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
        Text(
          context.tr('auth.reset_password_desc'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        AuthTextField(
          label: context.tr('auth.email'),
          hintText: 'you@business.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRequestOtp,
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
                    context.tr('auth.send_reset_code'),
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

  /// Step 2: OTP Verification (reusing common OtpVerificationView)
  Widget _buildOtpStep() {
    return OtpVerificationView(
      email: _emailCtrl.text.trim(),
      title: 'Verify OTP Code',
      subtitle:
          'We sent a 6-digit verification code to\n${_emailCtrl.text.trim()}',
      buttonLabel: 'Verify and Continue',
      onVerify: _handleVerifyOtp,
      onResend: _handleResendOtp,
      onBack: _back,
    );
  }

  /// Step 3: Set New Password
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _back,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                context.tr('auth.set_new_password_title'),
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
        Text(
          'Please enter and confirm your new password.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: context.tr('auth.new_password'),
          obscureText: true,
          controller: _newPasswordCtrl,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: context.tr('auth.confirm_new_password'),
          obscureText: true,
          controller: _confirmPasswordCtrl,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
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
                    context.tr('auth.set_password_btn'),
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

  /// Step 4: Success View
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.marigold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.inkTeal,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.tr('auth.reset_success_title'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('auth.reset_success_desc'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.tr('auth.back_to_login'),
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
