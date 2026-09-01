import 'package:flutter/material.dart';
import 'api_client.dart';
import '../theme/app_theme.dart';

/// Helper functions for simplified API calling and UI feedback.
class ApiHelper {
  static final ApiClient _client = ApiClient();

  /// Execute GET request with optional parser and query parameters.
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? parser,
    Map<String, String>? headers,
  }) {
    return _client.get<T>(
      endpoint,
      queryParams: queryParams,
      parser: parser,
      headers: headers,
    );
  }

  /// Execute POST request with payload and optional parser.
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic json)? parser,
    Map<String, String>? headers,
  }) {
    return _client.post<T>(
      endpoint,
      body: body,
      parser: parser,
      headers: headers,
    );
  }

  /// Execute PUT request with payload and optional parser.
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic json)? parser,
    Map<String, String>? headers,
  }) {
    return _client.put<T>(
      endpoint,
      body: body,
      parser: parser,
      headers: headers,
    );
  }

  /// Execute PATCH request with payload and optional parser.
  static Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic json)? parser,
    Map<String, String>? headers,
  }) {
    return _client.patch<T>(
      endpoint,
      body: body,
      parser: parser,
      headers: headers,
    );
  }

  /// Execute DELETE request.
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? parser,
    Map<String, String>? headers,
  }) {
    return _client.delete<T>(
      endpoint,
      parser: parser,
      headers: headers,
    );
  }

  /// Display a floating error snackbar for failed API calls.
  static void showErrorSnackBar(BuildContext context, String? message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message ?? 'An unexpected error occurred.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Display a floating success snackbar for successful API calls.
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

