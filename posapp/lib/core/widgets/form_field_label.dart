import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable label widget for form fields.
/// Displays a red asterisk (*) if the field is required.
/// Does NOT display any "(optional)" tag for non-required fields.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.fontSize = 13.0,
    this.bottomPadding = 6.0,
    this.color,
  });

  final String label;
  final bool isRequired;
  final double fontSize;
  final double bottomPadding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: RichText(
        text: TextSpan(
          text: label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ) ??
              TextStyle(
                color: color ?? AppColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
