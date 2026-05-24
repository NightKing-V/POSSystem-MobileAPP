import 'dart:async';
import '../domain/auth_models.dart';

abstract class AuthService {
  Future<UserSession> login({required String email, required String password});
  Future<UserSession> register({required String fullName, required String email, required String password});
  Future<void> logout();
  Future<UserSession> getCurrentSession();
}

class MockAuthService implements AuthService {
  // Simulating small network latency
  static const Duration _latency = Duration(milliseconds: 1000);

  // In-memory session tracking for the mockup
  UserSession _currentSession = UserSession.empty;

  // Predefined mock profiles
  static final Map<String, UserProfile> _mockProfiles = {
    'admin@cloudpos.com': const UserProfile(
      uid: 'u-admin-1',
      fullName: 'Sarah Jenkins',
      email: 'admin@cloudpos.com',
      role: UserRole.admin,
      businessId: 'b-coffee-101',
      businessName: 'Coffee & Co. Roasters',
    ),
    'manager@cloudpos.com': const UserProfile(
      uid: 'u-manager-1',
      fullName: 'Marcus Vance',
      email: 'manager@cloudpos.com',
      role: UserRole.manager,
      businessId: 'b-coffee-101',
      businessName: 'Coffee & Co. Roasters',
    ),
    'cashier@cloudpos.com': const UserProfile(
      uid: 'u-cashier-1',
      fullName: 'Emily Rose',
      email: 'cashier@cloudpos.com',
      role: UserRole.cashier,
      businessId: 'b-coffee-101',
      businessName: 'Coffee & Co. Roasters',
    ),
    // A fresh sign-up user who has NOT set up their business/subscription yet
    'new@cloudpos.com': const UserProfile(
      uid: 'u-new-99',
      fullName: 'Alex Carter',
      email: 'new@cloudpos.com',
      role: UserRole.admin, // Subscribed owner
      businessId: null,
      businessName: null,
    ),
  };

  @override
  Future<UserSession> login({required String email, required String password}) async {
    await Future.delayed(_latency);

    final sanitizedEmail = email.trim().toLowerCase();
    if (_mockProfiles.containsKey(sanitizedEmail)) {
      final user = _mockProfiles[sanitizedEmail]!;
      _currentSession = UserSession(user: user, isAuthenticated: true);
      return _currentSession;
    } else {
      // Fallback: If user signs up dynamically, we dynamically create a session without business context
      final user = UserProfile(
        uid: 'u-dyn-${DateTime.now().millisecondsSinceEpoch}',
        fullName: email.split('@').first.toUpperCase(),
        email: sanitizedEmail,
        role: UserRole.admin,
        businessId: null,
        businessName: null,
      );
      _currentSession = UserSession(user: user, isAuthenticated: true);
      return _currentSession;
    }
  }

  @override
  Future<UserSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(_latency);

    final sanitizedEmail = email.trim().toLowerCase();
    // Simulate user creation
    final newUser = UserProfile(
      uid: 'u-dyn-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: sanitizedEmail,
      role: UserRole.admin, // Default registration role is Business Owner
      businessId: null,
      businessName: null,
    );

    // Save mock user for active session login persistence
    _mockProfiles[sanitizedEmail] = newUser;
    _currentSession = UserSession(user: newUser, isAuthenticated: true);
    return _currentSession;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentSession = UserSession.empty;
  }

  @override
  Future<UserSession> getCurrentSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentSession;
  }
}
