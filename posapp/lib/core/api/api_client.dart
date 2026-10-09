import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'token_storage.dart';

/// API Response wrapper containing status code, data, error message, error code, and success flag.
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? errorMessage;
  final String? errorCode;
  final bool isSuccess;

  ApiResponse({
    required this.statusCode,
    this.data,
    this.errorMessage,
    this.errorCode,
    required this.isSuccess,
  });
}

/// Centralized Response Handler & API Client for all network requests.
class ApiClient {
  /// Global callback invoked whenever any API request returns a 401 Unauthorized
  static void Function()? onGlobalUnauthorized;

  final String baseUrl;
  final String? Function()? getToken;
  final void Function()? onUnauthorized;

  ApiClient({
    String? baseUrl,
    String? Function()? getToken,
    this.onUnauthorized,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       getToken = getToken ?? TokenStorage.getToken;

  /// Centralized HTTP Status Code Handling
  ApiResponse<T> _handleStatusCode<T>(
    http.Response response,
    T Function(dynamic json)? parser,
  ) {
    final statusCode = response.statusCode;
    dynamic bodyData;

    try {
      if (response.body.isNotEmpty) {
        bodyData = jsonDecode(response.body);
      }
    } catch (_) {
      bodyData = response.body;
    }

    final serverMessage = (bodyData is Map && bodyData.containsKey('message'))
        ? (bodyData['message'] is List
              ? (bodyData['message'] as List).join(', ')
              : bodyData['message'].toString())
        : (bodyData is Map && bodyData.containsKey('error')
              ? bodyData['error'].toString()
              : response.reasonPhrase);

    final errorCode = (bodyData is Map && bodyData.containsKey('code'))
        ? bodyData['code']?.toString()
        : null;

    switch (statusCode) {
      case 200:
      case 201:
      case 204:
        T? parsed;
        if (parser != null && bodyData != null) {
          parsed = parser(bodyData);
        } else if (bodyData is T) {
          parsed = bodyData;
        }
        return ApiResponse<T>(
          statusCode: statusCode,
          data: parsed,
          errorCode: errorCode,
          isSuccess: true,
        );

      case 400:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: serverMessage ?? 'Bad request.',
          errorCode: errorCode,
          isSuccess: false,
        );

      case 401:
        // Centralized unauthorized handling (token expiry / logout callback)
        TokenStorage.clear();
        onUnauthorized?.call();
        onGlobalUnauthorized?.call();
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage:
              serverMessage ?? 'Session expired. Please log in again.',
          errorCode: errorCode,
          isSuccess: false,
        );

      case 403:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: 'Access denied. You do not have permission.',
          errorCode: errorCode,
          isSuccess: false,
        );

      case 404:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: 'Requested resource was not found.',
          errorCode: errorCode,
          isSuccess: false,
        );

      case 422:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: serverMessage ?? 'Validation error occurred.',
          errorCode: errorCode,
          isSuccess: false,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: 'Server error ($statusCode). Please try again later.',
          errorCode: errorCode,
          isSuccess: false,
        );

      default:
        return ApiResponse<T>(
          statusCode: statusCode,
          errorMessage: serverMessage ?? 'Unexpected error ($statusCode).',
          errorCode: errorCode,
          isSuccess: false,
        );
    }
  }

  /// Request Headers Generator
  Map<String, String> _buildHeaders(Map<String, String>? extraHeaders) {
    final token = getToken?.call();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extraHeaders,
    };
  }

  /// Helper to build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final cleanParams = queryParams?.map((k, v) => MapEntry(k, v.toString()))
      ?..removeWhere((_, v) => v.isEmpty);
    final uri = Uri.parse('$baseUrl$endpoint');
    if (cleanParams != null && cleanParams.isNotEmpty) {
      return uri.replace(queryParameters: cleanParams);
    }
    return uri;
  }

  /// GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http.get(uri, headers: _buildHeaders(headers));
      return _handleStatusCode<T>(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage:
            'Network error: ${e.message}. Please check your connection.',
        isSuccess: false,
      );
    } catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  /// POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleStatusCode<T>(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage:
            'Network error: ${e.message}. Please check your connection.',
        isSuccess: false,
      );
    } catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  /// PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http.put(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleStatusCode<T>(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage:
            'Network error: ${e.message}. Please check your connection.',
        isSuccess: false,
      );
    } catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  /// PATCH Request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http.patch(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleStatusCode<T>(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage:
            'Network error: ${e.message}. Please check your connection.',
        isSuccess: false,
      );
    } catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  /// DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http.delete(uri, headers: _buildHeaders(headers));
      return _handleStatusCode<T>(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage:
            'Network error: ${e.message}. Please check your connection.',
        isSuccess: false,
      );
    } catch (e) {
      return ApiResponse<T>(
        statusCode: 0,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
}
