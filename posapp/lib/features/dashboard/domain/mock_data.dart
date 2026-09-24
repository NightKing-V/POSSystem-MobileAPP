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

final List<MockLocation> mockLocations = [];

final List<MockPermissionSet> mockPermissionSets = [];

final List<MockEmployee> mockEmployees = [];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String locationName(String locationId) =>
    mockLocations.firstWhere((l) => l.id == locationId,
        orElse: () => const MockLocation(
              id: '',
              name: 'Main Location',
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
              name: 'Staff Role',
              employeeCount: 0,
              permissions: {},
            )).name;

