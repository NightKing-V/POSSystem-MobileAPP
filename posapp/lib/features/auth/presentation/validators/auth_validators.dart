import '../../../../core/validation/validators.dart';

/// Dedicated validators for Authentication & User Registration
class AuthValidators {
  AuthValidators._();

  /// Email: Required, valid email format
  static final email = AppValidators.string()
      .required('Email address is required')
      .email('Please enter a valid email address');

  /// Login Password: Required
  static final loginPassword = AppValidators.string()
      .required('Password is required');

  /// Password: Required for account creation and password reset
  static final password = AppValidators.string()
      .required('Password is required')
      .password('Password must be at least 8 characters and include letters and numbers or symbols');

  /// Full Name: Required, min 2 chars, max 80 chars
  static final fullname = AppValidators.string()
      .required('Full name is required')
      .minLength(2, 'Name must be at least 2 characters')
      .maxLength(80, 'Name cannot exceed 80 characters');

  /// Phone: Optional/Required phone format
  static final phone = AppValidators.string()
      .phone('Please enter a valid phone number');

  /// OTP Code: Required 6 digits
  static final otp = AppValidators.string()
      .required('Verification code is required')
      .integer('Verification code must contain digits only')
      .minLength(6, 'Verification code must be 6 digits')
      .maxLength(6, 'Verification code must be 6 digits');
}
