import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  const AppException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  factory AppException.fromDio(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final dynamic responseData = error.response?.data;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppException(
        message: 'Connection timed out. Please try again.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AppException(
        message:
            'Unable to connect to the server. Check that the backend is running.',
      );
    }

    if (responseData is Map<String, dynamic>) {
      return AppException(
        message: _extractMessage(responseData),
        statusCode: statusCode,
        fieldErrors: responseData,
      );
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return AppException(
        message: responseData,
        statusCode: statusCode,
      );
    }

    return AppException(
      message: 'Something went wrong. Please try again.',
      statusCode: statusCode,
    );
  }

  static String _extractMessage(Map<String, dynamic> data) {
    final dynamic detail = data['detail'];

    if (detail != null) {
      return detail.toString();
    }

    final List<String> messages = <String>[];

    for (final MapEntry<String, dynamic> entry in data.entries) {
      final String fieldName = _formatFieldName(entry.key);
      final dynamic value = entry.value;

      if (value is List) {
        for (final dynamic item in value) {
          messages.add('$fieldName: ${item.toString()}');
        }
      } else if (value is String) {
        messages.add('$fieldName: $value');
      } else if (value != null) {
        messages.add('$fieldName: ${value.toString()}');
      }
    }

    if (messages.isNotEmpty) {
      return messages.join('\n');
    }

    return 'Registration failed. Please check your details and try again.';
  }

  static String _formatFieldName(String fieldName) {
    return switch (fieldName) {
      'password1' => 'Password',
      'password2' => 'Confirm password',
      'username' => 'Username',
      'email' => 'Email',
      _ => fieldName,
    };
  }

  @override
  String toString() {
    return 'AppException(statusCode: $statusCode, message: $message)';
  }
}