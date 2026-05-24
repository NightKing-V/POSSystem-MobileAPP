enum UserRole {
  admin('Business Owner', 'Full operational control, billing management, and user delegation.'),
  manager('Manager', 'Task assignments, inventory control, and checkout operations.'),
  cashier('Cashier', 'Register access, terminal checkout, and payment processing.');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String? businessId;
  final String? businessName;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.businessId,
    this.businessName,
  });

  UserProfile copyWith({
    String? fullName,
    UserRole? role,
    String? businessId,
    String? businessName,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
    );
  }
}

class UserSession {
  final UserProfile? user;
  final bool isAuthenticated;

  const UserSession({
    this.user,
    required this.isAuthenticated,
  });

  static const empty = UserSession(isAuthenticated: false);
}
