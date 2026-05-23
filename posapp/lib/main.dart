import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFCF8F8),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const IndustrialERPApp());
}

class IndustrialERPApp extends StatelessWidget {
  const IndustrialERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Industrial ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}