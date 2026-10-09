import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Country definition for phone input
class CountryCodeItem {
  final String name;
  final String code;
  final String flag;
  final int minDigits;
  final int maxDigits;

  const CountryCodeItem({
    required this.name,
    required this.code,
    required this.flag,
    this.minDigits = 7,
    this.maxDigits = 11,
  });
}

const List<CountryCodeItem> defaultCountryCodes = [
  CountryCodeItem(name: 'Sri Lanka', code: '+94', flag: '🇱🇰', minDigits: 9, maxDigits: 10),
  CountryCodeItem(name: 'India', code: '+91', flag: '🇮🇳', minDigits: 10, maxDigits: 10),
  CountryCodeItem(name: 'United States', code: '+1', flag: '🇺🇸', minDigits: 10, maxDigits: 10),
  CountryCodeItem(name: 'United Kingdom', code: '+44', flag: '🇬🇧', minDigits: 9, maxDigits: 11),
  CountryCodeItem(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪', minDigits: 9, maxDigits: 9),
  CountryCodeItem(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦', minDigits: 9, maxDigits: 9),
  CountryCodeItem(name: 'Qatar', code: '+974', flag: '🇶🇦', minDigits: 8, maxDigits: 8),
  CountryCodeItem(name: 'Singapore', code: '+65', flag: '🇸🇬', minDigits: 8, maxDigits: 8),
  CountryCodeItem(name: 'Malaysia', code: '+60', flag: '🇲🇾', minDigits: 9, maxDigits: 10),
  CountryCodeItem(name: 'Australia', code: '+61', flag: '🇦🇺', minDigits: 9, maxDigits: 10),
  CountryCodeItem(name: 'Canada', code: '+1', flag: '🇨🇦', minDigits: 10, maxDigits: 10),
  CountryCodeItem(name: 'Germany', code: '+49', flag: '🇩🇪', minDigits: 10, maxDigits: 11),
  CountryCodeItem(name: 'France', code: '+33', flag: '🇫🇷', minDigits: 9, maxDigits: 10),
  CountryCodeItem(name: 'Japan', code: '+81', flag: '🇯🇵', minDigits: 10, maxDigits: 11),
  CountryCodeItem(name: 'China', code: '+86', flag: '🇨🇳', minDigits: 11, maxDigits: 11),
];

class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.initialCountryCode = '+94',
    this.hintText,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.onCountryChanged,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String initialCountryCode;
  final String? hintText;
  final bool isRequired;
  final String? Function(String? value)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCountryChanged;
  final AutovalidateMode? autovalidateMode;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  late String _selectedCode;
  late FocusNode _effectiveFocusNode;
  bool _createdInternalFocusNode = false;
  bool _hasHadFocus = false;
  bool _hasBlurred = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialCountryCode;
    _parseInitialText();
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
  void didUpdateWidget(covariant PhoneInputField oldWidget) {
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
      // Focus lost (on-blur)
      if (!_hasBlurred) {
        setState(() {
          _hasBlurred = true;
        });
      }
      _fieldKey.currentState?.validate();
    }
  }

  void _parseInitialText() {
    final text = widget.controller.text.trim();
    if (text.startsWith('+')) {
      for (final country in defaultCountryCodes) {
        if (text.startsWith(country.code)) {
          _selectedCode = country.code;
          widget.controller.text = text.substring(country.code.length).trim();
          break;
        }
      }
    }
  }

  CountryCodeItem get _currentCountry =>
      defaultCountryCodes.firstWhere(
        (c) => c.code == _selectedCode,
        orElse: () => defaultCountryCodes.first,
      );

  String? _internalValidator(String? value) {
    final text = (value ?? '').trim();

    if (widget.isRequired && text.isEmpty) {
      return 'Phone number is required';
    }

    if (text.isNotEmpty) {
      final cleanDigits = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanDigits.length < _currentCountry.minDigits ||
          cleanDigits.length > _currentCountry.maxDigits) {
        return 'Enter a valid ${_currentCountry.minDigits}-${_currentCountry.maxDigits} digit number';
      }
    }

    if (widget.validator != null) {
      final fullNumber = text.isNotEmpty ? '$_selectedCode$text' : '';
      return widget.validator!(fullNumber);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAutovalidateMode = widget.autovalidateMode ??
        (_hasBlurred
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled);

    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      focusNode: _effectiveFocusNode,
      keyboardType: TextInputType.phone,
      autovalidateMode: effectiveAutovalidateMode,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
        LengthLimitingTextInputFormatter(_currentCountry.maxDigits + 2),
      ],
      validator: _internalValidator,
      onChanged: (val) {
        final fullPhone = val.trim().isNotEmpty ? '$_selectedCode${val.trim()}' : '';
        widget.onChanged?.call(fullPhone);
      },
      decoration: InputDecoration(
        hintText: widget.hintText ?? '77 123 4567',
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: AppColors.hairline, width: 1.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCode,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.slate, size: 20),
              isDense: true,
              borderRadius: BorderRadius.circular(8),
              items: defaultCountryCodes.map((c) {
                return DropdownMenuItem<String>(
                  value: c.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        c.code,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newCode) {
                if (newCode != null) {
                  setState(() => _selectedCode = newCode);
                  widget.onCountryChanged?.call(newCode);
                  final fullPhone = widget.controller.text.trim().isNotEmpty
                      ? '$newCode${widget.controller.text.trim()}'
                      : '';
                  widget.onChanged?.call(fullPhone);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
