import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/form_field_label.dart';

/// A labeled text field styled for the auth screens with on-blur validation and password visibility toggle.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.validator,
    this.isRequired = true,
    this.autovalidateMode,
    this.onChanged,
  });

  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool isRequired;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  late bool _obscured = widget.obscureText;
  late FocusNode _effectiveFocusNode;
  bool _createdInternalFocusNode = false;
  bool _hasHadFocus = false;
  bool _hasBlurred = false;

  @override
  void initState() {
    super.initState();
    _initFocusNode();
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _effectiveFocusNode = widget.focusNode!;
      _createdInternalFocusNode = false;
    } else {
      _effectiveFocusNode = FocusNode();
      _createdInternalFocusNode = true;
    }
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      if (_createdInternalFocusNode) {
        _effectiveFocusNode.dispose();
      }
      _initFocusNode();
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (_createdInternalFocusNode) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasFocus) {
      _hasHadFocus = true;
    } else if (_hasHadFocus && !_effectiveFocusNode.hasFocus) {
      // Focus lost (on-blur event)
      if (!_hasBlurred) {
        setState(() {
          _hasBlurred = true;
        });
      }
      _fieldKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAutovalidateMode = widget.autovalidateMode ??
        (_hasBlurred
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(
          label: widget.label,
          isRequired: widget.isRequired,
        ),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          focusNode: _effectiveFocusNode,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autovalidateMode: effectiveAutovalidateMode,
          onChanged: widget.onChanged,
          style: const TextStyle(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.slate,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}