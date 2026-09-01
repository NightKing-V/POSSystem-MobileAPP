import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/token_storage.dart';

/// DTO for User Login
class LoginDto {
  final String email;
  final String password;

  const LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };
}

/// DTO for User Registration
class RegisterDto {
  final String email;
  final String password;
  final String? fullname;
  final String? phone;
  final String? businessName;
  final String? businessType;

  const RegisterDto({
    required this.email,
    required this.password,
    this.fullname,
    this.phone,
    this.businessName,
    this.businessType,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
        if (fullname?.isNotEmpty == true) 'fullname': fullname,
        if (phone?.isNotEmpty == true) 'phone': phone,
        if (businessName?.isNotEmpty == true) 'businessName': businessName,
        if (businessType?.isNotEmpty == true) 'businessType': businessType,
      };
}

/// DTO for OTP Verification
class VerifyOtpDto {
  final String email;
  final String token;

  const VerifyOtpDto({required this.email, required this.token});

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'token': token.trim(),
      };
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Login user with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final dto = LoginDto(email: email, password: password);
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      body: dto.toJson(),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      // Extract access token from response (handling NestJS / Supabase session output)
      String? token;
      if (data.containsKey('access_token')) {
        token = data['access_token'] as String?;
      } else if (data.containsKey('session') && data['session'] is Map) {
        token = data['session']['access_token'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }

      if (data.containsKey('user') && data['user'] is Map) {
        TokenStorage.setCurrentUser(data['user'] as Map<String, dynamic>);
      }
    }

    return response;
  }

  /// Register new user with email and password
  Future<ApiResponse<Map<String, dynamic>>> register(RegisterDto dto) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      body: dto.toJson(),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      String? token;
      if (data.containsKey('access_token')) {
        token = data['access_token'] as String?;
      } else if (data.containsKey('session') && data['session'] is Map) {
        token = data['session']['access_token'] as String?;
      }

      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }
    }

    return response;
  }

  /// Verify signup OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(VerifyOtpDto dto) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.verify,
      body: dto.toJson(),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      String? token = data['accessToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }
      if (data.containsKey('user') && data['user'] is Map) {
        TokenStorage.setCurrentUser(data['user'] as Map<String, dynamic>);
      }
    }

    return response;
  }

  /// Logout user and clear tokens
  Future<void> logout() async {
    await TokenStorage.clear();
  }
}
