import '../../../../core/validation/validators.dart';

/// Dedicated validators for Inventory & Catalog management
class InventoryValidators {
  InventoryValidators._();

  /// Product Name: Required, min 2 chars, max 100 chars
  static final productName = AppValidators.string()
      .required('Product name is required')
      .minLength(2, 'Product name must be at least 2 characters')
      .maxLength(100, 'Product name cannot exceed 100 characters');

  /// SKU: Optional/Required, alphanumeric/dashes, max 50 chars
  static final sku = AppValidators.string()
      .maxLength(50, 'SKU cannot exceed 50 characters');

  /// Category Selection
  static final category = AppValidators.string()
      .required('Please select a category');

  /// Cost Price: Positive number (>= 0)
  static final costPrice = AppValidators.string()
      .number('Cost price must be a valid number')
      .positive('Cost price cannot be negative');

  /// Selling Price: Required, positive number (> 0)
  static final sellingPrice = AppValidators.string()
      .required('Selling price is required')
      .number('Selling price must be a valid number')
      .strictlyPositive('Selling price must be greater than 0');

  /// Stock Quantity: Required integer, >= 0
  static final stockQuantity = AppValidators.string()
      .required('Stock quantity is required')
      .integer('Stock quantity must be a whole number')
      .positive('Stock quantity cannot be negative');

  /// Category Name: Required, min 2 chars, max 60 chars
  static final categoryName = AppValidators.string()
      .required('Category name is required')
      .minLength(2, 'Category name must be at least 2 characters')
      .maxLength(60, 'Category name cannot exceed 60 characters');

  /// Category Description: Optional, max 255 chars
  static final categoryDescription = AppValidators.string()
      .maxLength(255, 'Description cannot exceed 255 characters');
}
