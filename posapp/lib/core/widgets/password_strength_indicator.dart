import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../validation/password_strength.dart';

/// Interactive UI widget that displays a 4-bar strength meter and rule checklist.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showChecklist = true,
  });

  final String password;
  final bool showChecklist;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = PasswordStrength.calculate(password);

    String localizedLabel() {
      switch (result.level) {
        case PasswordStrengthLevel.none:
          return '';
        case PasswordStrengthLevel.weak:
          return context.tr('auth.password_weak');
        case PasswordStrengthLevel.fair:
          return context.tr('auth.password_fair');
        case PasswordStrengthLevel.good:
          return context.tr('auth.password_good');
        case PasswordStrengthLevel.strong:
          return context.tr('auth.password_strong');
      }
    }

    final label = localizedLabel();
    final effectiveLabel = (label.isNotEmpty && !label.startsWith('auth.')) ? label : result.label;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Segmented Progress Bar & Label ──────────────────────────
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(4, (index) {
                    final isFilled = index < result.score;
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: isFilled
                              ? result.color
                              : AppColors.hairline.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: result.color,
                ),
                child: Text(effectiveLabel),
              ),
            ],
          ),

          // ── Requirements Checklist ─────────────────────────────────
          if (showChecklist) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _RuleItem(
                  label: context.tr('auth.rule_min_chars'),
                  fallback: '8+ chars',
                  passed: result.hasMinLength,
                ),
                _RuleItem(
                  label: context.tr('auth.rule_uppercase'),
                  fallback: 'Uppercase (A-Z)',
                  passed: result.hasUppercase,
                ),
                _RuleItem(
                  label: context.tr('auth.rule_number'),
                  fallback: 'Number (0-9)',
                  passed: result.hasDigit,
                ),
                _RuleItem(
                  label: context.tr('auth.rule_special'),
                  fallback: r'Special (!@#$)',
                  passed: result.hasSpecial,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({
    required this.label,
    required this.fallback,
    required this.passed,
  });

  final String label;
  final String fallback;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final text = (label.isNotEmpty && !label.startsWith('auth.')) ? label : fallback;
    final color = passed ? const Color(0xFF2E7D32) : AppColors.slate;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: passed ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
