import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Login user with email and password
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
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
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    String? businessName,
    String? phone,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      body: {
        'email': email,
        'password': password,
        if (businessName != null) 'businessName': businessName,
        if (phone != null) 'phone': phone,
      },
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

  /// Logout user and clear tokens
  Future<void> logout() async {
    await TokenStorage.clear();
  }
}
