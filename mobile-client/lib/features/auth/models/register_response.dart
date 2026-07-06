import 'package:mapetite/core/models/api_error_response.dart';

sealed class RegisterResult {}

class RegisterSuccess extends RegisterResult {
  final String detail;

  RegisterSuccess({required this.detail});

  factory RegisterSuccess.fromJson(Map<String, dynamic> json) {
    return RegisterSuccess(
      detail: json['detail'] as String? ?? 'Registration successful.',
    );
  }
}

class RegisterError extends RegisterResult {
  final ApiErrorResponse error;

  RegisterError(this.error);
}
