import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  const AppException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  factory AppException.fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Connection timed out. Please try again.',
      DioExceptionType.connectionError => 'No internet connection.',
      _ =>
        (responseData is Map && responseData['detail'] != null)
            ? responseData['detail'] as String
            : 'Something went wrong.',
    };
    return AppException(
      message: message,
      statusCode: statusCode,
      responseData: responseData,
    );
  }

  factory AppException.unauthorised() => const AppException(
    message: 'Session expired. Please log in again.',
    statusCode: 401,
  );

  factory AppException.notFound(String resource) =>
      AppException(message: '$resource not found.', statusCode: 404);

  @override
  String toString() => 'AppException($statusCode): $message';
}
