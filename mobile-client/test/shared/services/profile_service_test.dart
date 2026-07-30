import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/services/profile_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

const _testUsername = 'integration_test';
const _testPassword = 'IntegrationTest123!';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    final response = await ApiClient.post(
      ApiEndpoints.login,
      data: {'username': _testUsername, 'password': _testPassword},
    );
    await AuthTokenService.saveTokens(
      AuthTokens.fromJson(response.data as Map<String, dynamic>),
    );
  });

  group('ProfileService (integration — requires local backend running and seeded)', () {
    final service = ProfileService();

    test('getProfile returns the nested profile map', () async {
      final profile = await service.getProfile();

      expect(profile, contains('dine_in_budget'));
      expect(profile, contains('grocery_budget'));
      expect(profile, contains('spending_alert_percent'));
    });

    test('updateProfile persists budget fields and getProfile reflects them', () async {
      await service.updateProfile({
        'dine_in_budget': 250,
        'grocery_budget': 350,
        'spending_alert_percent': 75,
      });

      try {
        final profile = await service.getProfile();

        expect(double.parse(profile['dine_in_budget'].toString()), 250.0);
        expect(double.parse(profile['grocery_budget'].toString()), 350.0);
        expect(profile['spending_alert_percent'], 75);
      } finally {
        // Reset to baseline so other tests/tasks see a clean profile.
        // This runs unconditionally, even if assertions above fail.
        await service.updateProfile({
          'dine_in_budget': null,
          'grocery_budget': null,
          'spending_alert_percent': 80,
        });
      }
    });

    test('updateProfile surfaces the backend\'s specific validation message '
        'instead of a generic one', () async {
      // spending_alert_percent is validated server-side with max_value=100
      // (server/apps/users/serializers.py) — sending 999 forces a real 400
      // whose body is the plain field-error shape
      // {"spending_alert_percent": ["Ensure this value is less than or
      // equal to 100."]}, the same shape a duplicate-username rejection
      // uses for the "username" field.
      await expectLater(
        service.updateProfile({'spending_alert_percent': 999}),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            allOf(
              isNot('Something went wrong.'),
              contains('100'),
            ),
          ),
        ),
      );
    });
  });
}
