import '../../../../core/validation/validators.dart';

/// Dedicated validators for Suppliers & Purchase Orders
class SupplierValidators {
  SupplierValidators._();

  /// Supplier Name: Required, min 2 chars, max 100 chars
  static final supplierName = AppValidators.string()
      .required('Supplier name is required')
      .minLength(2, 'Supplier name must be at least 2 characters')
      .maxLength(100, 'Supplier name cannot exceed 100 characters');

  /// Contact Person: Optional, max 80 chars
  static final contactPerson = AppValidators.string()
      .maxLength(80, 'Contact person cannot exceed 80 characters');

  /// Phone: Optional, valid phone format
  static final phone = AppValidators.string()
      .phone('Please enter a valid phone number');

  /// Email: Optional, valid email format
  static final email = AppValidators.string()
      .email('Please enter a valid email address');

  /// Address: Optional, max 200 chars
  static final address = AppValidators.string()
      .maxLength(200, 'Address cannot exceed 200 characters');

  /// Notes: Optional, max 500 chars
  static final notes = AppValidators.string()
      .maxLength(500, 'Notes cannot exceed 500 characters');

  /// PO Item Quantity: Required integer, > 0
  static final poItemQty = AppValidators.string()
      .required('Quantity is required')
      .integer('Quantity must be a whole number')
      .strictlyPositive('Quantity must be at least 1');

  /// PO Unit Cost: Required positive number (>= 0)
  static final poUnitCost = AppValidators.string()
      .required('Unit cost is required')
      .number('Unit cost must be a valid number')
      .positive('Unit cost cannot be negative');
}
