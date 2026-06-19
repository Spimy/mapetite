import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const AppException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory AppException.fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Connection timed out. Please try again.',
      DioExceptionType.connectionError =>
        'Unable to connect to the server.',
      _ => _extractMessage(data),
    };

    return AppException(
      message: message,
      statusCode: statusCode,
      errors: data is Map<String, dynamic> ? data : null,
    );
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        return data['detail'].toString();
      }

      for (final entry in data.entries) {
        final value = entry.value;

        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String) {
          return value;
        }
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return 'Something went wrong. Please try again.';
  }

  factory AppException.unauthorised() {
    return const AppException(
      message: 'Session expired. Please log in again.',
      statusCode: 401,
    );
  }

  factory AppException.notFound(String resource) {
    return AppException(
      message: '$resource not found.',
      statusCode: 404,
    );
  }

  @override
  String toString() => 'AppException($statusCode): $message';
}