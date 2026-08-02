import 'package:dio/dio.dart';
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
      throw _mapValidationError(e);
    }
  }

  /// Takes raw bytes (not a file path) because `MultipartFile.fromFile`
  /// relies on `dart:io`, which doesn't work on Flutter web — image_picker's
  /// web implementation returns a blob reference, not a real filesystem
  /// path. Reading bytes via XFile.readAsBytes() works on every platform.
  Future<void> uploadAvatar(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: filename),
      });
      await ApiClient.patch(ApiEndpoints.me, data: formData);
    } on AppException catch (e) {
      throw _mapValidationError(e);
    }
  }

  AppException _mapValidationError(AppException e) {
    if (e.statusCode != null &&
        e.statusCode! >= 400 &&
        e.statusCode! < 500 &&
        e.responseData is Map<String, dynamic>) {
      final error = ApiErrorResponse.fromJson(e.responseData);
      return AppException(
        message: error.displayMessage,
        statusCode: e.statusCode,
        responseData: e.responseData,
      );
    }

    return e;
  }
}
