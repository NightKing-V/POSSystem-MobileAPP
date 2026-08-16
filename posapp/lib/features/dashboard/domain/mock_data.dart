/// In-memory mock data for Business Hierarchy screens.
/// Replace with repository calls when wiring to a real backend.
library mock_data;

// ─── Models ──────────────────────────────────────────────────────────────────

class MockLocation {
  const MockLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.employeeCount,
    required this.taxRate,
    required this.timezone,
    required this.currency,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final int employeeCount;
  final double taxRate;
  final String timezone;
  final String currency;
  final bool isActive;
}

class MockPermissionSet {
  const MockPermissionSet({
    required this.id,
    required this.name,
    required this.employeeCount,
    required this.permissions,
  });

  final String id;
  final String name;
  final int employeeCount;
  final Map<String, bool> permissions;
}

class MockEmployee {
  const MockEmployee({
    required this.id,
    required this.name,
    required this.contact,
    required this.locationId,
    required this.permissionSetId,
    required this.pin,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String contact;
  final String locationId;
  final String permissionSetId;
  final String pin;
  final bool isActive;
}

// ─── Permission Categories ────────────────────────────────────────────────────

const List<String> kPermissionCategories = [
  'POS Access',
  'Discounts',
  'Refunds',
  'Reports',
  'Inventory',
  'Settings',
];

// ─── Dummy Data ───────────────────────────────────────────────────────────────

final List<MockLocation> mockLocations = [
  const MockLocation(
    id: 'loc1',
    name: 'Main Branch',
    address: '12 High Street, Colombo 03',
    employeeCount: 6,
    taxRate: 15.0,
    timezone: 'Asia/Colombo',
    currency: 'LKR',
    isActive: true,
  ),
  const MockLocation(
    id: 'loc2',
    name: 'Kandy Outlet',
    address: '44 Peradeniya Rd, Kandy',
    employeeCount: 4,
    taxRate: 15.0,
    timezone: 'Asia/Colombo',
    currency: 'LKR',
    isActive: true,
  ),
  const MockLocation(
    id: 'loc3',
    name: 'Galle Fort Kiosk',
    address: '7 Church Street, Galle Fort',
    employeeCount: 2,
    taxRate: 15.0,
    timezone: 'Asia/Colombo',
    currency: 'LKR',
    isActive: false,
  ),
];

final List<MockPermissionSet> mockPermissionSets = [
  MockPermissionSet(
    id: 'ps1',
    name: 'Store Manager',
    employeeCount: 3,
    permissions: {
      'POS Access': true,
      'Discounts': true,
      'Refunds': true,
      'Reports': true,
      'Inventory': true,
      'Settings': true,
    },
  ),
  MockPermissionSet(
    id: 'ps2',
    name: 'Cashier',
    employeeCount: 5,
    permissions: {
      'POS Access': true,
      'Discounts': true,
      'Refunds': false,
      'Reports': false,
      'Inventory': false,
      'Settings': false,
    },
  ),
  MockPermissionSet(
    id: 'ps3',
    name: 'Stock Clerk',
    employeeCount: 2,
    permissions: {
      'POS Access': false,
      'Discounts': false,
      'Refunds': false,
      'Reports': false,
      'Inventory': true,
      'Settings': false,
    },
  ),
];

final List<MockEmployee> mockEmployees = [
  const MockEmployee(
    id: 'e1',
    name: 'Ashan Perera',
    contact: '+94 71 234 5678',
    locationId: 'loc1',
    permissionSetId: 'ps1',
    pin: '1234',
    isActive: true,
  ),
  const MockEmployee(
    id: 'e2',
    name: 'Nimasha Silva',
    contact: '+94 77 876 5432',
    locationId: 'loc1',
    permissionSetId: 'ps2',
    pin: '5678',
    isActive: true,
  ),
  const MockEmployee(
    id: 'e3',
    name: 'Kasun Fernando',
    contact: '+94 76 111 2233',
    locationId: 'loc2',
    permissionSetId: 'ps2',
    pin: '9012',
    isActive: true,
  ),
  const MockEmployee(
    id: 'e4',
    name: 'Dilini Jayawardena',
    contact: '+94 70 444 5566',
    locationId: 'loc2',
    permissionSetId: 'ps3',
    pin: '3456',
    isActive: false,
  ),
  const MockEmployee(
    id: 'e5',
    name: 'Ruwan Dissanayake',
    contact: '+94 78 999 0011',
    locationId: 'loc3',
    permissionSetId: 'ps1',
    pin: '7890',
    isActive: true,
  ),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String locationName(String locationId) =>
    mockLocations.firstWhere((l) => l.id == locationId,
        orElse: () => const MockLocation(
              id: '',
              name: 'Unknown',
              address: '',
              employeeCount: 0,
              taxRate: 0,
              timezone: '',
              currency: '',
            )).name;

String permissionSetName(String psId) =>
    mockPermissionSets.firstWhere((p) => p.id == psId,
        orElse: () => MockPermissionSet(
              id: '',
              name: 'Unknown',
              employeeCount: 0,
              permissions: {},
            )).name;
