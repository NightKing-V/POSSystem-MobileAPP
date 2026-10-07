import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import './otp_box_input.dart';

/// A reusable 6-box OTP verification widget used across auth flows
/// (Signup email verification, Password reset, etc.).
///
/// Supports backend error payloads (OTP_EXPIRED, OTP_INVALID) and a real-time
/// countdown timer with resend functionality when the code expires.
class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
    required this.onVerify,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.onResend,
    this.onBack,
    this.errorText,
    this.expirySeconds,
    this.isLoading = false,
  });

  final String email;
  final Future<void> Function(String otp) onVerify;
  final String? title;
  final String? subtitle;
  final String? buttonLabel;
  final Future<void> Function()? onResend;
  final VoidCallback? onBack;
  final String? errorText;
  final int? expirySeconds;
  final bool isLoading;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpCtrl = TextEditingController();
  Timer? _countdownTimer;
  late int _remainingSeconds;
  bool _internalLoading = false;
  bool _isResending = false;
  String? _inlineError;

  int get _initialExpirySeconds =>
      widget.expirySeconds ?? ApiConstants.otpExpirySeconds;

  bool get _isExpired => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _initialExpirySeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (_remainingSeconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() {
          _remainingSeconds = 0;
          _inlineError = context.tr('auth.otp_expired');
        });
        timer.cancel();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      final h = hours.toString().padLeft(2, '0');
      final m = minutes.toString().padLeft(2, '0');
      final s = seconds.toString().padLeft(2, '0');
      return '$h:$m:$s';
    } else {
      final m = minutes.toString().padLeft(2, '0');
      final s = seconds.toString().padLeft(2, '0');
      return '$m:$s';
    }
  }

  Future<void> _handleVerify([String? code]) async {
    final token = (code ?? _otpCtrl.text).trim();
    if (token.length < 6) {
      setState(() {
        _inlineError = context.tr('auth.enter_otp');
      });
      return;
    }

    if (_isExpired) {
      setState(() {
        _inlineError = context.tr('auth.otp_expired');
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
        final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
        if (errorMsg.contains('OTP_EXPIRED') ||
            errorMsg.toLowerCase().contains('expired')) {
          setState(() {
            _inlineError = context.tr('auth.otp_expired');
            _remainingSeconds = 0;
            _countdownTimer?.cancel();
          });
        } else if (errorMsg.contains('OTP_INVALID') ||
            errorMsg.toLowerCase().contains('invalid otp')) {
          setState(() {
            _inlineError = context.tr('auth.invalid_otp');
          });
        } else {
          setState(() {
            _inlineError = errorMsg.isNotEmpty
                ? errorMsg
                : context.tr('common.error');
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _internalLoading = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (widget.onResend == null || _isResending) return;

    setState(() {
      _isResending = true;
      _inlineError = null;
    });

    try {
      await widget.onResend!();
      if (mounted) {
        _otpCtrl.clear();
        setState(() {
          _remainingSeconds = _initialExpirySeconds;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '').trim();
        setState(() {
          _inlineError = errorMsg.isNotEmpty
              ? errorMsg
              : context.tr('common.error');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLoading = widget.isLoading || _internalLoading;
    final effectiveError = widget.errorText ?? _inlineError;
    final effectiveTitle = widget.title ?? context.tr('auth.verify_email');
    final effectiveButtonLabel = widget.buttonLabel ?? context.tr('common.continue');

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
          effectiveTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle ?? context.tr('auth.otp_desc', args: {'email': widget.email}),
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
            onPressed: effectiveLoading || _isExpired ? null : () => _handleVerify(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inkTeal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.hairline,
              disabledForegroundColor: AppColors.slate,
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
                    _isExpired ? context.tr('auth.otp_expired') : effectiveButtonLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isExpired ? AppColors.slate : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (widget.onResend != null) ...[
          const SizedBox(height: 20),
          Center(
            child: _isExpired
                ? TextButton.icon(
                    onPressed: effectiveLoading || _isResending ? null : _handleResend,
                    icon: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.inkTeal,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      _isResending ? context.tr('common.loading') : context.tr('auth.resend_otp'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.slate),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('auth.resend_in', args: {'seconds': _formatDuration(_remainingSeconds)}),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: AppColors.slate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}
