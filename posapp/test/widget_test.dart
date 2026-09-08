import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:posapp/core/localization/app_locales.dart';
import 'package:posapp/core/localization/app_localizations.dart';
import 'package:posapp/core/theme/app_theme.dart';
import 'package:posapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:posapp/features/auth/presentation/widgets/otp_box_input.dart';
import 'package:posapp/features/auth/presentation/widgets/otp_verification_view.dart';
import 'package:posapp/features/settings/presentation/pages/settings_view.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppText.themeData(),
      locale: const Locale('en'),
      supportedLocales: AppLocales.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('ForgotPasswordPage renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ForgotPasswordPage(initialEmail: 'user@example.com')));
    await tester.pump();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });

  testWidgets('OtpVerificationView common component with OtpBoxInput renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OtpVerificationView(
              email: 'user@example.com',
              title: 'Verify OTP',
              onVerify: (otp) async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OtpVerificationView), findsOneWidget);
    expect(find.byType(OtpBoxInput), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsWidgets);
    expect(find.text('Verify and Continue'), findsOneWidget);
  });

  testWidgets('SettingsView renders Delete Business option properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SettingsView(
            businessName: 'Super Mart',
            orgId: 'org-test-123',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text('Super Mart'), findsOneWidget);
    expect(find.byIcon(Icons.delete_forever_rounded), findsOneWidget);
  });
}
