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
      throw StateError(
        'Unexpected registration response: ${response.statusCode}',
      );
    }

    final dynamic responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException(
        'The registration server response was invalid.',
      );
    }

    return RegisterResponse.fromJson(responseData);
  }
}