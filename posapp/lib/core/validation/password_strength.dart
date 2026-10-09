import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PasswordStrengthLevel { none, weak, fair, good, strong }

/// Result of evaluating password strength metrics
class PasswordStrengthResult {
  final PasswordStrengthLevel level;
  final int score; // 0 to 4
  final double fraction; // 0.0 to 1.0
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecial;

  const PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.fraction,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
  });

  bool get isValid => hasMinLength && (hasUppercase || hasLowercase) && (hasDigit || hasSpecial);

  Color get color {
    switch (level) {
      case PasswordStrengthLevel.none:
        return AppColors.hairline;
      case PasswordStrengthLevel.weak:
        return AppColors.error;
      case PasswordStrengthLevel.fair:
        return const Color(0xFFE67E22);
      case PasswordStrengthLevel.good:
        return const Color(0xFF2E7D32);
      case PasswordStrengthLevel.strong:
        return AppColors.inkTeal;
    }
  }

  String get label {
    switch (level) {
      case PasswordStrengthLevel.none:
        return '';
      case PasswordStrengthLevel.weak:
        return 'Weak';
      case PasswordStrengthLevel.fair:
        return 'Fair';
      case PasswordStrengthLevel.good:
        return 'Good';
      case PasswordStrengthLevel.strong:
        return 'Strong';
    }
  }
}

/// Helper class to compute password metrics and strength
class PasswordStrength {
  PasswordStrength._();

  static const int minLength = 8;
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\/\\[\]]');

  static PasswordStrengthResult calculate(String password) {
    if (password.isEmpty) {
      return const PasswordStrengthResult(
        level: PasswordStrengthLevel.none,
        score: 0,
        fraction: 0.0,
        hasMinLength: false,
        hasUppercase: false,
        hasLowercase: false,
        hasDigit: false,
        hasSpecial: false,
      );
    }

    final hasMinLength = password.length >= minLength;
    final hasUppercase = _uppercaseRegex.hasMatch(password);
    final hasLowercase = _lowercaseRegex.hasMatch(password);
    final hasDigit = _digitRegex.hasMatch(password);
    final hasSpecial = _specialRegex.hasMatch(password);

    int points = 0;
    if (hasMinLength) points++;
    if (password.length >= 12) points++;
    if (hasUppercase) points++;
    if (hasLowercase) points++;
    if (hasDigit) points++;
    if (hasSpecial) points++;

    PasswordStrengthLevel level;
    int score;
    double fraction;

    if (points <= 2) {
      level = PasswordStrengthLevel.weak;
      score = 1;
      fraction = 0.25;
    } else if (points <= 3) {
      level = PasswordStrengthLevel.fair;
      score = 2;
      fraction = 0.5;
    } else if (points <= 4) {
      level = PasswordStrengthLevel.good;
      score = 3;
      fraction = 0.75;
    } else {
      level = PasswordStrengthLevel.strong;
      score = 4;
      fraction = 1.0;
    }

    return PasswordStrengthResult(
      level: level,
      score: score,
      fraction: fraction,
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasDigit: hasDigit,
      hasSpecial: hasSpecial,
    );
  }
}
