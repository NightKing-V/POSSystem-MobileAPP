import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import './otp_box_input.dart';

/// A reusable 6-box OTP verification widget used across auth flows
/// (Signup email verification, Password reset, etc.).
class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
    required this.onVerify,
    this.title = 'Verify your email',
    this.subtitle,
    this.buttonLabel = 'Verify and Continue',
    this.onResend,
    this.onBack,
    this.errorText,
    this.isLoading = false,
  });

  final String email;
  final Future<void> Function(String otp) onVerify;
  final String title;
  final String? subtitle;
  final String buttonLabel;
  final Future<void> Function()? onResend;
  final VoidCallback? onBack;
  final String? errorText;
  final bool isLoading;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpCtrl = TextEditingController();
  bool _internalLoading = false;
  String? _inlineError;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify([String? code]) async {
    final token = (code ?? _otpCtrl.text).trim();
    if (token.length < 6) {
      setState(() {
        _inlineError = 'Please enter all 6 digits of the code.';
      });
      return;
    }

    setState(() {
      _inlineError = null;
      _internalLoading = true;
    });

    try {
      await widget.onVerify(token);
    } catch (e) {
      if (mounted) {
        setState(() {
          _inlineError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _internalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLoading = widget.isLoading || _internalLoading;
    final effectiveError = widget.errorText ?? _inlineError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.slate,
              ),
            ),
          ),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.marigold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.inkTeal,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle ?? 'We sent a 6-digit code to\n${widget.email}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        // 6-box segmented OTP input
        OtpBoxInput(
          controller: _otpCtrl,
          length: 6,
          hasError: effectiveError != null,
          onChanged: (_) {
            if (_inlineError != null) {
              setState(() => _inlineError = null);
            }
          },
          onCompleted: (code) {
            _handleVerify(code);
          },
        ),
        if (effectiveError != null) ...[
          const SizedBox(height: 14),
          Text(
            effectiveError,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: effectiveLoading ? null : () => _handleVerify(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: effectiveLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.buttonLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (widget.onResend != null) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: effectiveLoading ? null : widget.onResend,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.inkTeal,
              ),
              child: const Text(
                'Resend code',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
