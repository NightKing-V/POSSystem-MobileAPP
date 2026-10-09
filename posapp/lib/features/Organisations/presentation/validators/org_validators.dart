import '../../../../core/validation/validators.dart';

/// Dedicated validators for Business & Organization creation
class OrgValidators {
  OrgValidators._();

  /// Business Name: Required, min 2 chars, max 100 chars
  static final businessName = AppValidators.string()
      .required('Business name is required')
      .minLength(2, 'Business name must be at least 2 characters')
      .maxLength(100, 'Business name cannot exceed 100 characters');

  /// Phone: Optional, valid phone format
  static final phone = AppValidators.string()
      .phone('Please enter a valid phone number');

  /// Address: Optional, max 200 chars
  static final address = AppValidators.string()
      .maxLength(200, 'Address cannot exceed 200 characters');
}
