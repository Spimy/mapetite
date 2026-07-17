import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/services/store_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

const _testUsername = 'integration_test';
const _testPassword = 'IntegrationTest123!';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // `flutter test` installs a mock HttpOverrides that makes every real
    // HttpClient return an empty 400 response (see
    // package:flutter_test/src/_binding_io.dart). These tests need genuine
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

  group('StoreService (integration — requires local backend running and seeded)', () {
    final service = StoreService();

    test('getStores filters by type', () async {
      final groceries = await service.getStores(type: StoreType.grocery);

      expect(groceries, isNotEmpty);
      expect(groceries.every((s) => s.merchantType == StoreType.grocery), isTrue);
    });

    test('getNearbyStores returns stores sorted with distance populated', () async {
      final nearby = await service.getNearbyStores(
        lat: 3.0731,
        lng: 101.6069,
        radiusKm: 10,
        type: StoreType.grocery,
      );

      expect(nearby, isNotEmpty);
      expect(nearby.first.distanceKm, isNotNull);
    });

    test('getStoreDetail returns a single fully-populated store', () async {
      final stores = await service.getStores(type: StoreType.grocery);
      final id = stores.first.id;

      final detail = await service.getStoreDetail(id);

      expect(detail.id, id);
      expect(detail.operatingHours, isNotEmpty);
    });

    test('getStoreItems returns items for a store', () async {
      final stores = await service.getStores(type: StoreType.grocery);
      final id = stores.first.id;

      final items = await service.getStoreItems(id);

      expect(items, isNotEmpty);
      expect(items.first.price, greaterThan(0));
    });
  });
}
