import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/core/utils/opening_hours_util.dart';
import 'package:mapetite/features/restaurants/screens/restaurant_listing_screen.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

const _storeA = StoreModel(
  id: '1',
  businessName: 'Nasi Kandar Ali',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
  operatingHours: [
    OperatingHourModel(
      dayOfWeek: 0,
      isClosed: false,
      openTime: '00:00:00',
      closeTime: '23:59:00',
    ),
  ],
  distanceKm: 0.5,
);

Widget _wrap(Widget child, {required List<Override> overrides}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('shows a loading skeleton while the provider is loading',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith(
          (ref, query) => Completer<List<StoreModel>>().future,
        ),
      ],
    ));

    await tester.pump();

    expect(find.byType(RestaurantListingScreen), findsOneWidget);
    expect(find.text('No restaurants found'), findsNothing);
  });

  testWidgets('shows the generic error state for a non-network error',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith(
          (ref, query) => Future<List<StoreModel>>.error('network error'),
        ),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('shows NetworkErrorState for an AppException with isNetworkError',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith(
          (ref, query) => Future<List<StoreModel>>.error(
            const AppException(
              message: 'No internet connection.',
              isNetworkError: true,
            ),
          ),
        ),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Could not connect.'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('renders real store data from the provider', (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nasi Kandar Ali'), findsOneWidget);
  });

  testWidgets(
      'shows a "nothing nearby" empty state with Try Again when no restaurants are returned',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider
            .overrideWith((ref, query) async => <StoreModel>[]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nothing nearby.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets(
      'shows "No restaurants found" with Clear Filters when a search narrows non-empty results to zero',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA]),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pumpAndSettle();

    expect(find.text('No restaurants found'), findsOneWidget);
    expect(find.text('Clear Filters'), findsOneWidget);
  });
}
