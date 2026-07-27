import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/network/refresh_interceptor.dart';
import 'package:mapetite/features/auth/controllers/auth_controller.dart';
import 'package:mapetite/features/auth/models/current_user.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

class _UnauthorisedAuthService extends AuthService {
  @override
  Future<CurrentUser> getCurrentUser() async {
    throw AppException.unauthorised();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'fake-access',
      'auth_refresh_token': 'fake-refresh',
    });
    await StorageService.init();
  });

  test(
    'loadCurrentUser sets sessionExpired true and clears tokens on a 401',
    () async {
      final controller = AuthController(_UnauthorisedAuthService());

      final result = await controller.loadCurrentUser();

      expect(result, isFalse);
      expect(controller.state.sessionExpired, isTrue);
      expect(controller.state.currentUser, isNull);
      expect(AuthTokenService.hasTokens, isFalse);
    },
  );

  test('logout() does not set sessionExpired', () async {
    final controller = AuthController(_UnauthorisedAuthService());

    await controller.logout();

    expect(controller.state.sessionExpired, isFalse);
  });

  test(
    'the refresh-interceptor session-expiry hook flips sessionExpired on this controller',
    () async {
      final controller = AuthController(_UnauthorisedAuthService());

      onSessionExpired?.call();

      expect(controller.state.sessionExpired, isTrue);
    },
  );
}
