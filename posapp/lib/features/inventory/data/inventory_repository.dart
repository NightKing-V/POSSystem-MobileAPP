import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../domain/models/product.dart';

/// DTO for creating a Category in the backend
class CreateCategoryDto {
  final String name;
  final String? parentId;

  const CreateCategoryDto({
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        if (parentId?.isNotEmpty == true) 'parent_id': parentId,
      };
}

/// Category Model parsed from Backend API
class CategoryProps {
  final String id;
  final String name;
  final String? parentId;
  final int level;

  const CategoryProps({
    required this.id,
    required this.name,
    this.parentId,
    this.level = 0,
  });

  factory CategoryProps.fromJson(Map<String, dynamic> json) {
    return CategoryProps(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Category',
      parentId: json['parent_id']?.toString(),
      level: json['level'] is int ? json['level'] as int : 0,
    );
  }
}

/// DTO for creating a Product in the backend
class CreateProductDto {
  final String name;
  final String subcategoryId;
  final String? brandId;
  final String? supplierId;
  final String? sku;
  final String? barcode;
  final double? initialPrice;

  const CreateProductDto({
    required this.name,
    required this.subcategoryId,
    this.brandId,
    this.supplierId,
    this.sku,
    this.barcode,
    this.initialPrice,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'subcategoryid': subcategoryId,
        if (brandId?.isNotEmpty == true) 'brandid': brandId,
        if (supplierId?.isNotEmpty == true) 'supplier_id': supplierId,
        if (sku?.isNotEmpty == true) 'SKU': sku,
        if (barcode?.isNotEmpty == true) 'barcode': barcode,
        'initialPrice': ?initialPrice,
      };
}

/// DTO for Product Pricing
class CreateProductPriceDto {
  final double price;
  final String currency;
  final bool isDefault;

  const CreateProductPriceDto({
    required this.price,
    this.currency = 'LKR',
    this.isDefault = true,
  });

  Map<String, dynamic> toJson() => {
        'price': price,
        'currency': currency,
        'isdefault': isDefault,
      };
}

/// Inventory & Products Repository
class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all products from API
  Future<ApiResponse<List<Product>>> fetchProducts() async {
    return _apiClient.get<List<Product>>(
      ApiConstants.products,
      parser: (json) {
        if (json is List) {
          return json.map((e) {
            final map = e as Map<String, dynamic>;
            double resolvedPrice = 0.0;
            if (map.containsKey('prices') &&
                map['prices'] is List &&
                (map['prices'] as List).isNotEmpty) {
              final firstPrice = map['prices'][0];
              if (firstPrice is Map && firstPrice.containsKey('price')) {
                resolvedPrice = double.tryParse(firstPrice['price'].toString()) ?? 0.0;
              }
            }

            String catName = 'General';
            if (map.containsKey('category') && map['category'] is Map) {
              catName = map['category']['name']?.toString() ?? 'General';
            }

            return Product(
              id: map['id']?.toString() ?? '',
              name: map['name']?.toString() ?? 'Product',
              sku: map['SKU']?.toString() ?? map['barcode']?.toString() ?? '',
              price: resolvedPrice > 0 ? resolvedPrice : 100.0,
              category: catName,
            );
          }).toList();
        }
        return [];
      },
    );
  }

  /// Create a new Product
  Future<ApiResponse<Map<String, dynamic>>> createProduct(
    CreateProductDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.products,
      body: dto.toJson(),
    );
  }

  /// Fetch all product categories
  Future<ApiResponse<List<CategoryProps>>> fetchCategories() async {
    return _apiClient.get<List<CategoryProps>>(
      ApiConstants.categories,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => CategoryProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new product category
  Future<ApiResponse<Map<String, dynamic>>> createCategory(
    CreateCategoryDto dto,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.categories,
      body: dto.toJson(),
    );
  }

  /// Delete a product category
  Future<ApiResponse<Map<String, dynamic>>> deleteCategory(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      '${ApiConstants.categories}/$id',
    );
  }
}

