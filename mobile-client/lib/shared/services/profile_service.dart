import '../../core/errors/app_exception.dart';
import '../../core/models/api_error_response.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get(ApiEndpoints.me);
    final data = response.data as Map<String, dynamic>;
    return data['profile'] as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await ApiClient.patch(ApiEndpoints.me, data: data);
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
