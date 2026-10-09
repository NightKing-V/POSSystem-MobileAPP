import '../../../../core/validation/validators.dart';

/// Dedicated validators for Customer management
class CustomerValidators {
  CustomerValidators._();

  /// Customer Name: Required, min 2 chars, max 80 chars
  static final name = AppValidators.string()
      .required('Customer name is required')
      .minLength(2, 'Customer name must be at least 2 characters')
      .maxLength(80, 'Customer name cannot exceed 80 characters');

  /// Customer Phone: Required phone format
  static final phone = AppValidators.string()
      .required('Phone number is required')
      .phone('Please enter a valid phone number');

  /// Customer Email: Optional, valid email format
  static final email = AppValidators.string()
      .email('Please enter a valid email address');

  /// Customer Address: Optional, max 200 chars
  static final address = AppValidators.string()
      .maxLength(200, 'Address cannot exceed 200 characters');
}
