import '../../../../core/validation/validators.dart';

/// Dedicated validators for Locations & Branches
class LocationValidators {
  LocationValidators._();

  /// Branch / Location Name: Required, min 2 chars, max 80 chars
  static final branchName = AppValidators.string()
      .required('Branch name is required')
      .minLength(2, 'Branch name must be at least 2 characters')
      .maxLength(80, 'Branch name cannot exceed 80 characters');

  /// Address: Optional, max 200 chars
  static final address = AppValidators.string()
      .maxLength(200, 'Address cannot exceed 200 characters');

  /// Phone: Optional, valid phone format
  static final phone = AppValidators.string()
      .phone('Please enter a valid phone number');
}
