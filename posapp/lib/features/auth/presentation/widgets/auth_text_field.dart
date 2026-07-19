import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// A labeled text field styled for the auth screens.
/// UI only — no validation or submit logic wired up yet.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
  });

  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: AppColors.ink, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.slate,
            size: 20,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        )
            : null,
      ),
    );
  }
}