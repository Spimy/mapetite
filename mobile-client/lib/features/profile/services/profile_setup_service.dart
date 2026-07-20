import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/profile/models/profile_setup_data.dart';

class ProfileSetupService {
  Future<void> saveProfileSetup(ProfileSetupData data) async {
    await ApiClient.patch(
      ApiEndpoints.me,
      data: data.toProfileJson(),
    );
  }
}