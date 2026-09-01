import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './core/localization/app_locales.dart';
import './core/localization/app_localizations.dart';
import './core/localization/locale_controller.dart';
import './core/theme/app_theme.dart';
import './features/auth/presentation/pages/splash_page.dart';

void main() {
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