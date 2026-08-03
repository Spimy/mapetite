import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/core/network/refresh_interceptor.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

const _testUsername = 'integration_test';
const _testPassword = 'IntegrationTest123!';

Future<AuthTokens> _login() async {
  final response = await ApiClient.post(
    ApiEndpoints.login,
    data: {'username': _testUsername, 'password': _testPassword},
  );
  return AuthTokens.fromJson(response.data as Map<String, dynamic>);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // `flutter test` installs a mock HttpOverrides that makes every real
    // HttpClient return an empty 400 response (see
    // package:flutter_test/src/_binding_io.dart). The integration tests
    // below need genuine network access to the local backend, so disable it.
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('shouldAttemptRefresh (pure logic)', () {
    test('returns true for 403 with token_not_valid code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'stores/'),
        response: Response(
          requestOptions: RequestOptions(path: 'stores/'),
          statusCode: 403,
          data: {'code': 'token_not_valid'},
        ),
      );
      expect(shouldAttemptRefresh(err), isTrue);
    });

    test('returns false for the refresh endpoint itself', () {
      final err = DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
          statusCode: 403,
          data: {'code': 'token_not_valid'},
        ),
      );
      expect(shouldAttemptRefresh(err), isFalse);
    });

    test('returns true for a 403 with not_authenticated code (missing/malformed auth header)', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'stores/'),
        response: Response(
          requestOptions: RequestOptions(path: 'stores/'),
          statusCode: 403,
          data: {'detail': 'Authentication credentials were not provided.', 'code': 'not_authenticated'},
        ),
      );
      expect(shouldAttemptRefresh(err), isTrue);
    });

    test('returns false for a plain 403 with no token_not_valid code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: 'stores/5/'),
        response: Response(
          requestOptions: RequestOptions(path: 'stores/5/'),
          statusCode: 403,
          data: {'detail': 'You do not have permission.'},
        ),
      );
      expect(shouldAttemptRefresh(err), isFalse);
    });

    test(
      'returns false when the request has already been retried once, '
      'even if it still looks like token_not_valid (prevents infinite '
      'refresh/retry loop)',
      () {
        final requestOptions = RequestOptions(path: 'stores/');
        requestOptions.extra['__retried'] = true;
        final err = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 403,
            data: {'code': 'token_not_valid'},
          ),
        );
        expect(shouldAttemptRefresh(err), isFalse);
      },
    );
  });

  group('ApiClient auth refresh (integration — requires local backend running)', () {
    test('transparently refreshes an expired token and retries the request', () async {
      final tokens = await _login();
      await AuthTokenService.saveTokens(
        AuthTokens(access: 'deliberately-invalid-token', refresh: tokens.refresh),
      );

      final response = await ApiClient.get('stores/');

      expect(response.statusCode, 200);
      expect(AuthTokenService.accessToken, isNot('deliberately-invalid-token'));
    });

    test('clears tokens and throws when the refresh token is also invalid', () async {
      await AuthTokenService.saveTokens(
        const AuthTokens(access: 'bad-access', refresh: 'bad-refresh'),
      );

      var sessionExpiredCalled = false;
      onSessionExpired = () => sessionExpiredCalled = true;
      addTearDown(() => onSessionExpired = null);

      await expectLater(
        () => ApiClient.get('stores/'),
        throwsA(isA<AppException>()),
      );

      expect(sessionExpiredCalled, isTrue);
    });
  });
}
