import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/errors/app_exception.dart';

void main() {
  group('AppException.fromDio', () {
    test('isNetworkError is true for connection-related Dio exception types', () {
      final requestOptions = RequestOptions(path: '/test');

      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        final dioException =
            DioException(requestOptions: requestOptions, type: type);
        final appException = AppException.fromDio(dioException);
        expect(appException.isNetworkError, isTrue, reason: 'for $type');
      }
    });

    test('isNetworkError is false for a server error response', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 500),
      );

      final appException = AppException.fromDio(dioException);
      expect(appException.isNetworkError, isFalse);
    });
  });

  test('AppException.unauthorised() is not a network error', () {
    expect(AppException.unauthorised().isNetworkError, isFalse);
  });

  test('AppException.notFound() is not a network error', () {
    expect(AppException.notFound('Recipe').isNetworkError, isFalse);
  });
}
