import '../../../../core/validation/validators.dart';

/// Dedicated validators for Staff & Org Roles
class StaffValidators {
  StaffValidators._();

  /// Employee Full Name: Required, min 2 chars, max 80 chars
  static final employeeName = AppValidators.string()
      .required('Employee name is required')
      .minLength(2, 'Name must be at least 2 characters')
      .maxLength(80, 'Name cannot exceed 80 characters');

  /// Employee Email: Required valid email
  static final email = AppValidators.string()
      .required('Email address is required')
      .email('Please enter a valid email address');

  /// Password: Required for new users, min 8 chars with letters & numbers/symbols
  static final password = AppValidators.string()
      .required('Password is required')
      .password('Password must be at least 8 characters and include letters and numbers or symbols');

  /// Phone: Optional, valid phone format
  static final phone = AppValidators.string()
      .phone('Please enter a valid phone number');

  /// Role Name: Required, min 2 chars, max 60 chars
  static final roleName = AppValidators.string()
      .required('Role name is required')
      .minLength(2, 'Role name must be at least 2 characters')
      .maxLength(60, 'Role name cannot exceed 60 characters');

  /// Role Description: Optional, max 255 chars
  static final roleDescription = AppValidators.string()
      .maxLength(255, 'Description cannot exceed 255 characters');
}
