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

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return RegisterResponse.fromJson(data);
    }

    return const RegisterResponse(
      detail: 'Registration successful. Please check your email.',
    );
  }

  // TODO: Implement login functionality after register works.
}