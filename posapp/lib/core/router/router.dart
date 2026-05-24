import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/onboarding/presentation/business_setup_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      // Listen to AuthController state changes to automatically re-evaluate redirects!
      refreshListenable: authController,
      redirect: (context, state) {
        final isAuthenticated = authController.isAuthenticated;
        final hasBusiness = authController.currentUser?.businessId != null;
        
        final isSplashing = state.matchedLocation == '/';
        final isLoggingIn = state.matchedLocation == '/login';
        final isRegistering = state.matchedLocation == '/register';
        final isOnboarding = state.matchedLocation == '/business-setup';
        final isDashboard = state.matchedLocation == '/dashboard';

        // 1. If we are on the splash screen, let it load and handle its own routing trigger
        if (isSplashing) return null;

        // 2. If the user is NOT logged in:
        if (!isAuthenticated) {
          // Allow access to login and registration, otherwise force redirect to /login
          if (isLoggingIn || isRegistering) return null;
          return '/login';
        }

        // 3. If the user IS logged in:
        if (isAuthenticated) {
          // A. If they don't have an active business associated with their account:
          if (!hasBusiness) {
            // Force them to complete the subscription onboarding / business setup wizard
            if (isOnboarding) return null;
            return '/business-setup';
          }

          // B. If they DO have an active business:
          // Prevent them from going back to login/register or onboarding screens
          if (isLoggingIn || isRegistering || isOnboarding) {
            return '/dashboard';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/business-setup',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BusinessSetupScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri.path}'),
        ),
      ),
    );
  }
}
