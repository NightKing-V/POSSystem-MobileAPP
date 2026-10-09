import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/token_storage.dart';
import '../domain/models/product.dart';

/// DTO for creating a Category in the backend
class CreateCategoryDto {
  final String? orgId;
  final String name;
  final String? parentId;

  const CreateCategoryDto({
    this.orgId,
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toJson([String? defaultOrgId]) {
    final effectiveOrgId =
        orgId ?? defaultOrgId ?? TokenStorage.currentOrgId ?? '';
    return {
      'org_id': effectiveOrgId,
      'name': name.trim(),
      if (parentId?.isNotEmpty == true) 'parent_id': parentId,
    };
  }
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
  final String? orgId;
  final String name;
  final String subcategoryId;
  final String? brandId;
  final String? supplierId;
  final String? sku;
  final String? barcode;
  final double? initialPrice;

  const CreateProductDto({
    this.orgId,
    required this.name,
    required this.subcategoryId,
    this.brandId,
    this.supplierId,
    this.sku,
    this.barcode,
    this.initialPrice,
  });

  Map<String, dynamic> toJson([String? defaultOrgId]) {
    final effectiveOrgId =
        orgId ?? defaultOrgId ?? TokenStorage.currentOrgId ?? '';
    return {
      'org_id': effectiveOrgId,
      'name': name.trim(),
      'subcategoryid': subcategoryId,
      if (brandId?.isNotEmpty == true) 'brandid': brandId,
      if (supplierId?.isNotEmpty == true) 'supplier_id': supplierId,
      if (sku?.isNotEmpty == true) 'SKU': sku,
      if (barcode?.isNotEmpty == true) 'barcode': barcode,
      if (initialPrice != null) 'initialPrice': initialPrice,
    };
  }
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

/// Inventory Location Props matching backend /inventory model
class InventoryLocationProps {
  final String id;
  final String orgId;
  final String name;
  final String type; // BRANCH, WAREHOUSE, DOCK
  final String? address;
  final String? phone;
  final bool isActive;

  const InventoryLocationProps({
    required this.id,
    required this.orgId,
    required this.name,
    this.type = 'BRANCH',
    this.address,
    this.phone,
    this.isActive = true,
  });

  factory InventoryLocationProps.fromJson(Map<String, dynamic> json) {
    return InventoryLocationProps(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? json['orgId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Branch',
      type: json['type']?.toString() ?? 'BRANCH',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['is_active'] != false && json['status'] != 'inactive',
    );
  }
}

/// DTO for creating an inventory location
class CreateInventoryLocationDto {
  final String? orgId;
  final String name;
  final String type; // BRANCH, WAREHOUSE, DOCK
  final String? address;
  final String? phone;
  final bool? isActive;

  const CreateInventoryLocationDto({
    this.orgId,
    required this.name,
    this.type = 'BRANCH',
    this.address,
    this.phone,
    this.isActive = true,
  });

  Map<String, dynamic> toJson([String? defaultOrgId]) {
    final effectiveOrgId =
        orgId ?? defaultOrgId ?? TokenStorage.currentOrgId ?? '';
    return {
      'org_id': effectiveOrgId,
      'name': name.trim(),
      'type': type.toUpperCase(),
      if (address?.isNotEmpty == true) 'address': address!.trim(),
      if (phone?.isNotEmpty == true) 'phone': phone!.trim(),
      if (isActive != null) 'is_active': isActive,
    };
  }
}

/// Inventory, Products & Locations Repository
class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all products for organization
  Future<ApiResponse<List<Product>>> fetchProducts({String? orgId}) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    final query = effectiveOrgId != null ? {'orgId': effectiveOrgId} : null;

    return _apiClient.get<List<Product>>(
      ApiConstants.products,
      queryParams: query,
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
                resolvedPrice =
                    double.tryParse(firstPrice['price'].toString()) ?? 0.0;
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

  /// Create a new Product (with org_id)
  Future<ApiResponse<Map<String, dynamic>>> createProduct(
    CreateProductDto dto, {
    String? orgId,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.products,
      body: dto.toJson(orgId),
    );
  }

  /// Update a Product (PATCH /products/:id)
  Future<ApiResponse<Map<String, dynamic>>> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.product(id),
      body: data,
    );
  }

  /// Delete a product (DELETE /products/:id)
  Future<ApiResponse<Map<String, dynamic>>> deleteProduct(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.product(id),
    );
  }

  /// Fetch all product categories for organization
  Future<ApiResponse<List<CategoryProps>>> fetchCategories({String? orgId}) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    final query = effectiveOrgId != null ? {'orgId': effectiveOrgId} : null;

    return _apiClient.get<List<CategoryProps>>(
      ApiConstants.categories,
      queryParams: query,
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

  /// Create a new product category (with org_id)
  Future<ApiResponse<Map<String, dynamic>>> createCategory(
    CreateCategoryDto dto, {
    String? orgId,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.categories,
      body: dto.toJson(orgId),
    );
  }

  /// Update a product category (PATCH /categories/:id)
  Future<ApiResponse<Map<String, dynamic>>> updateCategory(
    String id,
    CreateCategoryDto dto, {
    String? orgId,
  }) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.category(id),
      body: dto.toJson(orgId),
    );
  }

  /// Delete a product category (DELETE /categories/:id)
  Future<ApiResponse<Map<String, dynamic>>> deleteCategory(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.category(id),
    );
  }

  /// Fetch all locations / branches for organization
  Future<ApiResponse<List<InventoryLocationProps>>> fetchLocations({
    String? orgId,
  }) async {
    final effectiveOrgId = orgId ?? TokenStorage.currentOrgId;
    final query = effectiveOrgId != null ? {'orgId': effectiveOrgId} : null;

    return _apiClient.get<List<InventoryLocationProps>>(
      ApiConstants.inventory,
      queryParams: query,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) =>
                  InventoryLocationProps.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Create a new inventory location / branch (POST /inventory)
  Future<ApiResponse<Map<String, dynamic>>> createLocation(
    CreateInventoryLocationDto dto, {
    String? orgId,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiConstants.inventory,
      body: dto.toJson(orgId),
    );
  }

  /// Update an inventory location (PATCH /inventory/:id)
  Future<ApiResponse<Map<String, dynamic>>> updateLocation(
    String id,
    Map<String, dynamic> body,
  ) async {
    return _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.inventoryLocation(id),
      body: body,
    );
  }

  /// Delete an inventory location (DELETE /inventory/:id)
  Future<ApiResponse<Map<String, dynamic>>> deleteLocation(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.inventoryLocation(id),
    );
  }
}
