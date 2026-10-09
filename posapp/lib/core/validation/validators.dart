typedef ValidationRule<T> = String? Function(T value);

/// Fluent, Yup-like validator for string form fields
class StringValidator {
  final List<ValidationRule<String?>> _rules = [];

  /// Marks the field as required
  StringValidator required([String? message]) {
    _rules.add((val) {
      if (val == null || val.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    });
    return this;
  }

  /// Validates minimum character length
  StringValidator minLength(int length, [String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && val.trim().length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    });
    return this;
  }

  /// Validates maximum character length
  StringValidator maxLength(int length, [String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && val.trim().length > length) {
        return message ?? 'Cannot exceed $length characters';
      }
      return null;
    });
    return this;
  }

  /// Validates email address format
  StringValidator email([String? message]) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && !emailRegex.hasMatch(val.trim())) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    });
    return this;
  }

  /// Validates phone number format
  StringValidator phone([String? message]) {
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,15}$');
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && !phoneRegex.hasMatch(val.trim())) {
        return message ?? 'Please enter a valid phone number';
      }
      return null;
    });
    return this;
  }

  /// Validates that the input is a valid number
  StringValidator number([String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
        return message ?? 'Must be a valid number';
      }
      return null;
    });
    return this;
  }

  /// Validates that the input is a positive number (>= 0)
  StringValidator positive([String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty) {
        final n = double.tryParse(val.trim());
        if (n == null || n < 0) {
          return message ?? 'Must be greater than or equal to 0';
        }
      }
      return null;
    });
    return this;
  }

  /// Validates that the number is strictly greater than zero (> 0)
  StringValidator strictlyPositive([String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty) {
        final n = double.tryParse(val.trim());
        if (n == null || n <= 0) {
          return message ?? 'Must be greater than 0';
        }
      }
      return null;
    });
    return this;
  }

  /// Validates minimum numeric value
  StringValidator minNumber(double min, [String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty) {
        final n = double.tryParse(val.trim());
        if (n == null || n < min) {
          return message ?? 'Must be at least $min';
        }
      }
      return null;
    });
    return this;
  }

  /// Validates password strength (minimum 8 chars, letter & number/special character)
  StringValidator password([String? message]) {
    _rules.add((val) {
      if (val != null && val.isNotEmpty) {
        if (val.length < 8) {
          return message ?? 'Password must be at least 8 characters';
        }
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(val);
        final hasDigitOrSpecial = RegExp(r'[0-9!@#$%^&*(),.?":{}|<>\-_=+\/\\[\]]').hasMatch(val);
        if (!hasLetter || !hasDigitOrSpecial) {
          return message ?? 'Password must include letters and numbers or symbols';
        }
      }
      return null;
    });
    return this;
  }

  /// Validates that the input is an integer
  StringValidator integer([String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && int.tryParse(val.trim()) == null) {
        return message ?? 'Must be a whole number';
      }
      return null;
    });
    return this;
  }

  /// Validates against a custom regex
  StringValidator matches(RegExp regex, [String? message]) {
    _rules.add((val) {
      if (val != null && val.trim().isNotEmpty && !regex.hasMatch(val.trim())) {
        return message ?? 'Invalid format';
      }
      return null;
    });
    return this;
  }

  /// Attaches a custom validation rule
  StringValidator custom(ValidationRule<String?> rule) {
    _rules.add(rule);
    return this;
  }

  /// Evaluates all rules in sequence and returns the first error message or null if valid
  String? validate(String? value) {
    for (final rule in _rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Callable helper so the validator can be passed directly to `TextFormField.validator`
  String? call(String? value) => validate(value);
}

/// Generic Yup-like builder class
class AppValidators {
  AppValidators._();

  /// Creates a new chainable String validator
  static StringValidator string() => StringValidator();
}
