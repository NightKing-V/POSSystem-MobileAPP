import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL resolution based on host platform
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Orgs / Business endpoints
  static const String orgs = '/orgs';

  // Products & Inventory endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String inventory = '/inventory';
}
