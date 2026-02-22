import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/secure_storage.dart';
import '../../config/app_config.dart';
import 'api_exceptions.dart';
import 'endpoints.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(SecureStorage());
});

class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;

  ApiClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    final authEndpoints = [
      Endpoints.signIn,
      Endpoints.signUp,
      Endpoints.refresh,
    ];
    if (!authEndpoints.contains(options.path)) {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 by attempting token refresh
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request
          final opts = error.requestOptions;
          final accessToken = await _secureStorage.getAccessToken();
          opts.headers['Authorization'] = 'Bearer $accessToken';
          final response = await _dio.fetch(opts);
          _isRefreshing = false;
          return handler.resolve(response);
        }
      } catch (e) {
        // Refresh failed, clear tokens and propagate error
        await _secureStorage.clearTokens();
      }
      _isRefreshing = false;
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        Endpoints.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.saveTokens(
          accessToken: data['token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      // Refresh failed
    }
    return false;
  }

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection',
            statusCode: statusCode);
      case DioExceptionType.badResponse:
        return _handleResponseError(statusCode, data);
      default:
        return NetworkException('Network error', statusCode: statusCode);
    }
  }

  AppException _handleResponseError(int? statusCode, dynamic data) {
    final message = _extractErrorMessage(data);

    switch (statusCode) {
      case 401:
        return AuthException(message ?? 'Authentication failed');
      case 403:
        return ForbiddenException(message ?? 'Access denied');
      case 404:
        return NotFoundException(message ?? 'Not found');
      case 422:
        final errors = _extractValidationErrors(data);
        return ValidationException(
          message ?? 'Validation failed',
          errors: errors,
        );
      case 429:
        final retryAfter = data?['retry_after'] ?? 60;
        return RateLimitException(
          message ?? 'Too many requests',
          retryAfter: retryAfter,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(message ?? 'Server error');
      default:
        return NetworkException(
          message ?? 'Request failed',
          statusCode: statusCode,
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      // Don't use HTML error pages as messages
      final trimmed = data.trim().toLowerCase();
      if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html')) {
        return null;
      }
      return data;
    }
    if (data is Map) {
      return data['error'] as String? ??
          data['message'] as String? ??
          (data['errors'] as List?)?.firstOrNull as String?;
    }
    return null;
  }

  List<String> _extractValidationErrors(dynamic data) {
    if (data == null) return [];
    if (data is Map && data['errors'] is List) {
      return (data['errors'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}
