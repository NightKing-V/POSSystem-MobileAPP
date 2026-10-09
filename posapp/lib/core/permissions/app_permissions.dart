/// Standardized Application Permission Keys (`<action>:<resource>`)
class AppPermissions {
  // 👑 Super / Platform Wildcards
  static const String all = '*:*';
  static const String manageAll = 'manage:all';

  // 🏢 Organizations (orgs)
  static const String orgsCreate = 'create:orgs';
  static const String orgsRead = 'read:orgs';
  static const String orgsUpdate = 'update:orgs';
  static const String orgsDelete = 'delete:orgs';
  static const String orgsManage = 'manage:orgs';

  // 👥 Users (users)
  static const String usersCreate = 'create:users';
  static const String usersRead = 'read:users';
  static const String usersUpdate = 'update:users';
  static const String usersDelete = 'delete:users';
  static const String usersManage = 'manage:users';

  // 🛡️ Roles & Permissions (roles, permissions)
  static const String rolesCreate = 'create:roles';
  static const String rolesRead = 'read:roles';
  static const String rolesUpdate = 'update:roles';
  static const String rolesDelete = 'delete:roles';
  static const String rolesManage = 'manage:roles';
  static const String permissionsRead = 'read:permissions';
  static const String permissionsManage = 'manage:permissions';

  // 📦 Products (products)
  static const String productsCreate = 'create:products';
  static const String productsRead = 'read:products';
  static const String productsUpdate = 'update:products';
  static const String productsDelete = 'delete:products';
  static const String productsManage = 'manage:products';

  // 🏷️ Categories & Brands (categories, brands)
  static const String categoriesCreate = 'create:categories';
  static const String categoriesRead = 'read:categories';
  static const String categoriesUpdate = 'update:categories';
  static const String categoriesDelete = 'delete:categories';
  static const String categoriesManage = 'manage:categories';

  static const String brandsCreate = 'create:brands';
  static const String brandsRead = 'read:brands';
  static const String brandsUpdate = 'update:brands';
  static const String brandsDelete = 'delete:brands';
  static const String brandsManage = 'manage:brands';

  // 📊 Inventory & Locations (inventory, locations)
  static const String inventoryCreate = 'create:inventory';
  static const String inventoryRead = 'read:inventory';
  static const String inventoryUpdate = 'update:inventory';
  static const String inventoryDelete = 'delete:inventory';
  static const String inventoryManage = 'manage:inventory';

  static const String locationsCreate = 'create:locations';
  static const String locationsRead = 'read:locations';
  static const String locationsUpdate = 'update:locations';
  static const String locationsDelete = 'delete:locations';
  static const String locationsManage = 'manage:locations';

  // 🚚 Suppliers & Purchase Orders (suppliers, purchase_orders)
  static const String suppliersCreate = 'create:suppliers';
  static const String suppliersRead = 'read:suppliers';
  static const String suppliersUpdate = 'update:suppliers';
  static const String suppliersDelete = 'delete:suppliers';
  static const String suppliersManage = 'manage:suppliers';

  static const String purchaseOrdersCreate = 'create:purchase_orders';
  static const String purchaseOrdersRead = 'read:purchase_orders';
  static const String purchaseOrdersUpdate = 'update:purchase_orders';
  static const String purchaseOrdersDelete = 'delete:purchase_orders';
  static const String purchaseOrdersManage = 'manage:purchase_orders';

  // 👤 Customers & Loyalty (customers, loyalty)
  static const String customersCreate = 'create:customers';
  static const String customersRead = 'read:customers';
  static const String customersUpdate = 'update:customers';
  static const String customersDelete = 'delete:customers';
  static const String customersManage = 'manage:customers';

  static const String loyaltyCreate = 'create:loyalty';
  static const String loyaltyRead = 'read:loyalty';
  static const String loyaltyUpdate = 'update:loyalty';
  static const String loyaltyDelete = 'delete:loyalty';
  static const String loyaltyManage = 'manage:loyalty';

  // 🏷️ Discounts (discounts)
  static const String discountsCreate = 'create:discounts';
  static const String discountsRead = 'read:discounts';
  static const String discountsUpdate = 'update:discounts';
  static const String discountsDelete = 'delete:discounts';
  static const String discountsManage = 'manage:discounts';

  // 🧾 Billing & Payments (bills, payments)
  static const String billsCreate = 'create:bills';
  static const String billsRead = 'read:bills';
  static const String billsUpdate = 'update:bills';
  static const String billsDelete = 'delete:bills';
  static const String billsManage = 'manage:bills';

  static const String paymentsCreate = 'create:payments';
  static const String paymentsRead = 'read:payments';
  static const String paymentsUpdate = 'update:payments';
  static const String paymentsDelete = 'delete:payments';
  static const String paymentsManage = 'manage:payments';
}
