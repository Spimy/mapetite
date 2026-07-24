import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'api_endpoints.dart';
import 'refresh_interceptor.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_isPublicEndpoint(options.path)) {
            options.headers.remove('Authorization');
          }

          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(RefreshInterceptor(dio));

    return dio;
  }

  static bool _isPublicEndpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return cleanPath == ApiEndpoints.login ||
        cleanPath == ApiEndpoints.refreshToken ||
        cleanPath == ApiEndpoints.verifyToken ||
        cleanPath == ApiEndpoints.register ||
        cleanPath == ApiEndpoints.resendEmail ||
        cleanPath == ApiEndpoints.googleLogin ||
        cleanPath == ApiEndpoints.verifyEmail;
  }

  static Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static AppException _mapError(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }

    return AppException.fromDio(e);
  }

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}