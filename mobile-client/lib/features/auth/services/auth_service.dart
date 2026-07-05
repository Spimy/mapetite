import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/models/api_error_response.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/register_request.dart';
import 'package:mapetite/features/auth/models/register_response.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {'token': 'mock_token_12345', 'userId': 'user_001'};
    // TODO: Replace with real API call to POST /api/v1/auth/login
  }

  Future<RegisterResult> register(RegisterRequest request) async {
    try {
      final response = await ApiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      // Successfully registered, return the success response
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

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Call POST /api/v1/auth/logout and clear stored token
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: Call POST /api/v1/auth/forgot-password
  }
}
