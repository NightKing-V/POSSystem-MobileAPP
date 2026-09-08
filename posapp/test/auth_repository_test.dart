import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/features/auth/data/auth_repository.dart';

void main() {
  group('AuthRepository DTO Tests', () {
    test('ForgotPasswordDto serialization', () {
      const dto = ForgotPasswordDto(
        email: '  test@business.com  ',
        redirectTo: 'https://app.pos.com/reset',
      );

      final json = dto.toJson();
      expect(json['email'], equals('test@business.com'));
      expect(json['redirectTo'], equals('https://app.pos.com/reset'));
    });

    test('ForgotPasswordDto serialization without redirectTo', () {
      const dto = ForgotPasswordDto(
        email: 'test@business.com',
      );

      final json = dto.toJson();
      expect(json['email'], equals('test@business.com'));
      expect(json.containsKey('redirectTo'), isFalse);
    });

    test('ResetPasswordDto serialization', () {
      const dto = ResetPasswordDto(
        newPassword: 'MyStrongPassword123!',
        accessToken: '  token-abc-123  ',
      );

      final json = dto.toJson();
      expect(json['newPassword'], equals('MyStrongPassword123!'));
      expect(json['accessToken'], equals('token-abc-123'));
    });

    test('VerifyOtpDto serialization with type', () {
      const dto = VerifyOtpDto(
        email: '  test@business.com  ',
        token: ' 123456 ',
        type: 'recovery',
      );

      final json = dto.toJson();
      expect(json['email'], equals('test@business.com'));
      expect(json['token'], equals('123456'));
      expect(json['type'], equals('recovery'));
    });
  });
}
