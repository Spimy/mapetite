import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/models/api_error_response.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/models/current_user.dart';
import 'package:mapetite/features/auth/models/login_request.dart';
import 'package:mapetite/features/auth/models/register_request.dart';
import 'package:mapetite/features/auth/models/register_response.dart';

class AuthService {
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.login,
        data: LoginRequest(
          email: email.trim(),
          password: password,
        ).toJson(),
      );

      return AuthTokens.fromJson(response.data as Map<String, dynamic>);
    } on AppException catch (e) {
      if (e.statusCode != null &&
          e.statusCode! >= 400 &&
          e.statusCode! < 500) {
        if (e.responseData is Map<String, dynamic>) {
          final error = ApiErrorResponse.fromJson(e.responseData);
          throw AppException(
            message: error.displayMessage,
            statusCode: e.statusCode,
            responseData: e.responseData,
          );
        }

        throw AppException(
          message: 'Invalid email or password.',
          statusCode: e.statusCode,
          responseData: e.responseData,
        );
      }

      rethrow;
    }
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final response = await ApiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;

    return AuthTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String? ?? refreshToken,
    );
  }

  Future<bool> verifyToken(String token) async {
    try {
      await ApiClient.post(
        ApiEndpoints.verifyToken,
        data: {'token': token},
      );

      return true;
    } on AppException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401) {
        return false;
      }

      rethrow;
    }
  }

  Future<CurrentUser> getCurrentUser() async {
    final response = await ApiClient.get(ApiEndpoints.me);

    return CurrentUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RegisterResult> register(RegisterRequest request) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return RegisterSuccess.fromJson(response.data);
    } on AppException catch (e) {
      if (e.statusCode != null &&
          e.statusCode! >= 400 &&
          e.statusCode! < 500 &&
          e.responseData != null) {
        return RegisterError(ApiErrorResponse.fromJson(e.responseData));
      }

      rethrow;
    }
  }

  Future<String> resendVerificationEmail(String email) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.resendEmail,
        data: {'email': email.trim()},
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final detail = data['detail']?.toString();

        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      }

      return 'Verification email sent.';
    } on AppException catch (e) {
      if (e.statusCode != null &&
          e.statusCode! >= 400 &&
          e.statusCode! < 500 &&
          e.responseData is Map<String, dynamic>) {
        final error = ApiErrorResponse.fromJson(e.responseData);
        throw AppException(
          message: error.displayMessage,
          statusCode: e.statusCode,
          responseData: e.responseData,
        );
      }

      rethrow;
    }
  }

}