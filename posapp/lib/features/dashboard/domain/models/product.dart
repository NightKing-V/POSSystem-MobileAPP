/// Immutable product data model.
///
/// Contains a static [mockProducts] list used for UI demonstration.
/// Swap this out with a real repository call when wiring to a backend.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.category,
  });

  final String id;
  final String name;
  final String sku;

  /// Unit selling price in local currency (Rs.).
  final double price;

  final String category;

  // ---------------------------------------------------------------------------
  // Mock catalogue — 12 products across 5 categories for UI demonstration.
  // ---------------------------------------------------------------------------
  static const List<Product> mockProducts = [
    Product(id: 'p01', name: 'Fresh Milk 1L',          sku: 'DRY-001', price: 450.0,  category: 'Dairy'),
    Product(id: 'p02', name: 'White Bread (Large)',     sku: 'BAK-002', price: 220.0,  category: 'Bakery'),
    Product(id: 'p03', name: 'Cheddar Cheese 200g',    sku: 'DRY-003', price: 980.0,  category: 'Dairy'),
    Product(id: 'p04', name: 'Orange Juice 1L',        sku: 'BEV-004', price: 380.0,  category: 'Beverages'),
    Product(id: 'p05', name: 'Basmati Rice 1kg',       sku: 'GRN-005', price: 560.0,  category: 'Grains'),
    Product(id: 'p06', name: 'Salted Butter 250g',     sku: 'DRY-006', price: 340.0,  category: 'Dairy'),
    Product(id: 'p07', name: 'Instant Coffee 200g',    sku: 'BEV-007', price: 1200.0, category: 'Beverages'),
    Product(id: 'p08', name: 'Potato Chips (Party)',   sku: 'SNK-008', price: 290.0,  category: 'Snacks'),
    Product(id: 'p09', name: 'Eggs (12 pack)',         sku: 'DRY-009', price: 720.0,  category: 'Dairy'),
    Product(id: 'p10', name: 'Mineral Water 2L',       sku: 'BEV-010', price: 120.0,  category: 'Beverages'),
    Product(id: 'p11', name: 'Whole Wheat Pasta',      sku: 'GRN-011', price: 430.0,  category: 'Grains'),
    Product(id: 'p12', name: 'Mixed Nuts 250g',        sku: 'SNK-012', price: 880.0,  category: 'Snacks'),
  ];
}
