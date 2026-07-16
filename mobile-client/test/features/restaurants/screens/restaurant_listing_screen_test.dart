import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
          // Never-completing future: keeps the provider in the "loading"
          // state for the duration of this test without leaving a real
          // pending Timer behind (unlike Future.delayed), which would trip
          // flutter_test's post-test "timer still pending" invariant check.
          (ref, query) => Completer<List<StoreModel>>().future,
        ),
      ],
    ));

    await tester.pump();

    expect(find.byType(RestaurantListingScreen), findsOneWidget);
    // No crash and no "no restaurants found" text while still loading.
    expect(find.text('No restaurants found'), findsNothing);
  });

  testWidgets('shows an empty state on error', (tester) async {
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

  testWidgets('shows empty state when no restaurants are returned',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantListingScreen(),
      overrides: [
        nearbyStoresProvider
            .overrideWith((ref, query) async => <StoreModel>[]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('No restaurants found'), findsOneWidget);
  });
}
