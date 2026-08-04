import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/features/notifications/services/notification_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

const _testUsername = 'integration_test';
const _testPassword = 'IntegrationTest123!';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // `flutter test` installs a mock HttpOverrides that makes every real
    // HttpClient return an empty 400 response. These tests need genuine
    // network access to the local backend, so disable it.
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

  group('NotificationService (integration — requires local backend running and seeded)', () {
    final service = NotificationService();

    test('getNotifications returns the authenticated user\'s notifications', () async {
      // Notifications are only ever created server-side (by a budget
      // alert), so this only asserts the request succeeds and returns the
      // right shape — not that it's non-empty.
      final notifications = await service.getNotifications();

      expect(notifications, isA<List>());
    });

    test('markRead and dismiss succeed against a real notification when one exists', () async {
      final notifications = await service.getNotifications();
      if (notifications.isEmpty) {
        markTestSkipped(
          'No notifications seeded for $_testUsername — trigger a budget '
          'alert (see Task 2) to exercise this path.',
        );
        return;
      }

      final target = notifications.first;
      await service.markRead(target.id);
      await service.dismiss(target.id);

      final after = await service.getNotifications();
      expect(after.any((n) => n.id == target.id), isFalse);
    });
  });
}
