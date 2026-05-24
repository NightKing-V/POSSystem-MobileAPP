import 'package:flutter/material.dart';
import '../domain/auth_models.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthController({required AuthService authService}) : _authService = authService;

  UserSession _currentSession = UserSession.empty;
  bool _isLoading = false;
  String? _errorMessage;

  UserSession get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession.isAuthenticated;
  UserProfile? get currentUser => _currentSession.user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _authService.getCurrentSession();
    } catch (e) {
      _errorMessage = 'Failed to load session: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentSession = UserSession.empty;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Invoked after business/subscription setup finishes, to bind the business to the active user session!
  void updateBusinessContext(String businessId, String businessName) {
    if (_currentSession.user != null) {
      final updatedUser = _currentSession.user!.copyWith(
        businessId: businessId,
        businessName: businessName,
      );
      _currentSession = UserSession(
        user: updatedUser,
        isAuthenticated: true,
      );
      notifyListeners();
    }
  }
}
