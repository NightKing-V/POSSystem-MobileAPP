import 'package:flutter/material.dart';
import '../../auth/controllers/auth_controller.dart';
import '../services/business_service.dart';

class BusinessSetupController extends ChangeNotifier {
  final BusinessService _businessService;

  BusinessSetupController({required BusinessService businessService})
      : _businessService = businessService;

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Form states
  String _businessName = '';
  String _businessCategory = 'Retail';
  String _currency = 'USD (\$)';
  String _location = 'United States';
  String _selectedPlan = 'Pro'; // Starter, Pro, Enterprise

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get businessName => _businessName;
  String get businessCategory => _businessCategory;
  String get currency => _currency;
  String get location => _location;
  String get selectedPlan => _selectedPlan;

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void setPlan(String plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void updateDetails({
    required String name,
    required String category,
    required String currency,
    required String location,
  }) {
    _businessName = name;
    _businessCategory = category;
    _currency = currency;
    _location = location;
    notifyListeners();
  }

  Future<bool> completeOnboarding(AuthController authController) async {
    if (_businessName.trim().isEmpty) {
      _errorMessage = 'Business name cannot be empty.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final business = await _businessService.registerBusiness(
        name: _businessName.trim(),
        category: _businessCategory,
        currency: _currency,
        location: _location,
        planTier: _selectedPlan,
      );

      // Successfully registered business. Bind it to user session!
      authController.updateBusinessContext(business.id, business.name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create business context: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    _businessName = '';
    _businessCategory = 'Retail';
    _currency = 'USD (\$)';
    _location = 'United States';
    _selectedPlan = 'Pro';
    notifyListeners();
  }
}
