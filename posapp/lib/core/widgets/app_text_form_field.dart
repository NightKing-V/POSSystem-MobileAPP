import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'form_field_label.dart';

/// Standard application text form field with intelligent on-blur validation.
///
/// Behavior:
/// 1. Initial / Pristine: No errors shown before the user ever touches this field.
/// 2. Other Fields Selected: Does NOT trigger errors on this field.
/// 3. On Blur (Focus Loss): Validates immediately when the user leaves/unfocuses this field.
/// 4. Post-Blur Editing: Live on-change validation so errors disappear immediately once resolved.
/// 5. Form Submission: When `FormState.validate()` is called, all fields validate.
class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.autofocus = false,
    this.autovalidateMode,
    this.decoration,
    this.style,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final TextStyle? style;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
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
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
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

    final inputDeco = widget.decoration ??
        InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
        );

    final field = TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: _effectiveFocusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      validator: widget.validator,
      autovalidateMode: effectiveAutovalidateMode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      autofocus: widget.autofocus,
      style: widget.style ?? const TextStyle(color: AppColors.ink, fontSize: 14),
      decoration: inputDeco,
    );

    if (widget.label != null && widget.label!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormFieldLabel(
            label: widget.label!,
            isRequired: widget.isRequired,
          ),
          field,
        ],
      );
    }

    return field;
  }
}
