import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Services
import 'features/auth/services/auth_service.dart';
import 'features/onboarding/services/business_service.dart';

// Controllers
import 'features/auth/controllers/auth_controller.dart';
import 'features/onboarding/controllers/business_setup_controller.dart';

// Routing & Theme
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile devices
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Premium status bar & navigation overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8FAFC), // Slate 50
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // Inject Core Mock Services (Frontend-only repository contracts)
        Provider<AuthService>(
          create: (_) => MockAuthService(),
        ),
        Provider<BusinessService>(
          create: (_) => MockBusinessService(),
        ),

        // Inject Application State Controllers
        ChangeNotifierProxyProvider<AuthService, AuthController>(
          create: (context) => AuthController(
            authService: context.read<AuthService>(),
          ),
          update: (_, service, previous) => previous ?? AuthController(authService: service),
        ),
        ChangeNotifierProxyProvider<BusinessService, BusinessSetupController>(
          create: (context) => BusinessSetupController(
            businessService: context.read<BusinessService>(),
          ),
          update: (_, service, previous) => previous ?? BusinessSetupController(businessService: service),
        ),
      ],
      child: const CloudPOSApp(),
    ),
  );
}

class CloudPOSApp extends StatelessWidget {
  const CloudPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Construct the GoRouter with active listenable bindings
    final appRouter = AppRouter.router(context);

    return MaterialApp.router(
      title: 'CloudPOS System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}