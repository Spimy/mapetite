import 'dart:async';
import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../../features/auth/models/auth_tokens.dart';
import '../../features/auth/services/auth_token_service.dart';
import '../errors/app_exception.dart';

/// True if this error represents an expired/invalid JWT that we should
/// attempt to refresh and retry, rather than a genuine permission or
/// server error. The backend returns 403 (not 401) with
/// `code: "token_not_valid"` for an expired/invalid access token.
bool shouldAttemptRefresh(DioException err) {
  if (err.requestOptions.path == ApiEndpoints.refreshToken) return false;

  final statusCode = err.response?.statusCode;
  if (statusCode != 401 && statusCode != 403) return false;

  final data = err.response?.data;
  if (data is Map && data['code'] == 'token_not_valid') return true;
  return statusCode == 401;
}

class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._dio);

  final Dio _dio;
  bool _isRefreshing = false;
  final List<Completer<void>> _waiters = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
      await _retryOrReject(err, handler);
      return;
    }

    _isRefreshing = true;
    final refreshToken = AuthTokenService.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      await _failRefresh(err, handler);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );
      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      await AuthTokenService.saveTokens(tokens);

      _isRefreshing = false;
      _releaseWaiters();
      await _retryOrReject(err, handler);
    } on DioException catch (_) {
      await _failRefresh(err, handler);
    }
  }

  Future<void> _failRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _isRefreshing = false;
    _releaseWaiters();
    await AuthTokenService.clearTokens();
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: AppException.unauthorised(),
      ),
    );
  }

  void _releaseWaiters() {
    for (final waiter in _waiters) {
      waiter.complete();
    }
    _waiters.clear();
  }

  Future<void> _retryOrReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final currentAuthHeader = _dio.options.headers['Authorization'];
    if (currentAuthHeader != null) {
      err.requestOptions.headers['Authorization'] = currentAuthHeader;
    }
    try {
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
