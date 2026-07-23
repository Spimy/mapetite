import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get(ApiEndpoints.me);
    final data = response.data as Map<String, dynamic>;
    return data['profile'] as Map<String, dynamic>;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await ApiClient.patch(ApiEndpoints.me, data: data);
  }
}
