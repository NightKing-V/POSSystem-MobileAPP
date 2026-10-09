import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './core/api/api_client.dart';
import './core/api/token_storage.dart';
import './core/localization/app_locales.dart';
import './core/localization/app_localizations.dart';
import './core/localization/locale_controller.dart';
import './core/permissions/permissions_service.dart';
import './core/theme/app_theme.dart';
import './features/auth/presentation/pages/login_page.dart';
import './features/auth/presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();

  // Setup global unauthorized redirect
  ApiClient.onGlobalUnauthorized = () {
    PermissionsService().clear();
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController(),
      builder: (context, _) {
        final locale = LocaleController().locale;
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'KIVI',
          debugShowCheckedModeBanner: false,
          theme: AppText.themeData(),
          locale: locale,
          supportedLocales: AppLocales.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
        );
      },
    );
  }
}