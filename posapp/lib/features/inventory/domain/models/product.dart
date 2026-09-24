/// Immutable product data model.
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
}
