import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/shared/services/storage_service.dart';

class AuthTokenService {
  AuthTokenService._();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  static String? get accessToken => StorageService.getString(_accessTokenKey);

  static String? get refreshToken => StorageService.getString(_refreshTokenKey);

  static bool get hasTokens {
    final access = accessToken;
    final refresh = refreshToken;

    return access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty;
  }

  static Future<void> saveTokens(AuthTokens tokens) async {
    await StorageService.setString(_accessTokenKey, tokens.access);
    await StorageService.setString(_refreshTokenKey, tokens.refresh);

    ApiClient.setAuthToken(tokens.access);
  }

  static Future<void> loadSavedAccessToken() async {
    final token = accessToken;

    if (token != null && token.isNotEmpty) {
      ApiClient.setAuthToken(token);
    }
  }

  static Future<void> clearTokens() async {
    await StorageService.remove(_accessTokenKey);
    await StorageService.remove(_refreshTokenKey);

    ApiClient.clearAuthToken();
  }
}