import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthService {
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    if (response.statusCode != 201) {
      throw AppException(
        message:
            'Registration failed. The server returned an unexpected response.',
        statusCode: response.statusCode,
      );
    }

    final dynamic responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw AppException(
        message:
            'Registration failed because the server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }

    return RegisterResponse.fromJson(responseData);
  }
}