import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/discovery/screens/map_explore_screen.dart';
import 'package:mapetite/shared/models/location_model.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/location_provider.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

// ─── Test fixtures ─────────────────────────────────────────────────────────

const _testRestaurant = StoreModel(
  id: 'r1',
  businessName: 'Test Restaurant',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
  category: 'Malaysian',
  latitude: 3.0738,
  longitude: 101.6055,
  distanceKm: 0.4,
);

const _testGrocery = StoreModel(
  id: 'g1',
  businessName: 'Test Grocer',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Jalan Grocer',
  category: 'Grocery',
  latitude: 3.0726,
  longitude: 101.6063,
  distanceKm: 0.5,
);

const _testGroceryNoCategory = StoreModel(
  id: 'g2',
  businessName: 'No Category Grocer',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Jalan Grocer 2',
  latitude: 3.0736,
  longitude: 101.6043,
);

const _defaultStores = [_testRestaurant, _testGrocery];

/// No location so the screen doesn't depend on a real Geolocator platform
/// channel being available in the test environment. The screen falls back
/// to its default map center, and the venue-marker fetch is independently
/// overridden below regardless of the query's lat/lng — a `null` result
/// here also avoids painting the pulsing user-location marker on top of
/// (and stealing taps from) the venue markers under test.
class _FixedLocationNotifier extends LocationNotifier {
  @override
  Future<LocationModel?> build() async => null;
}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/map',
      routes: [
        GoRoute(path: '/map', builder: (_, _) => const MapExploreScreen()),
        GoRoute(
          path: '/restaurants',
          builder: (_, _) => const Scaffold(body: Text('Restaurants')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => Scaffold(
                body: Text('RestaurantDetail:${state.pathParameters['id']}'),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/groceries',
          builder: (_, _) => const Scaffold(body: Text('Groceries')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => Scaffold(
                body: Text('GroceryDetail:${state.pathParameters['id']}'),
              ),
            ),
          ],
        ),
      ],
    );

typedef _StoresBuilder = Future<List<StoreModel>> Function(
  NearbyStoresQuery query,
);

Widget _routerWrap({
  List<StoreModel>? stores,
  _StoresBuilder? storesBuilder,
}) =>
    ProviderScope(
      overrides: [
        nearbyStoresProvider.overrideWith(
          (ref, query) =>
              (storesBuilder ?? (_) async => stores ?? _defaultStores)(query),
        ),
        locationProvider.overrideWith(_FixedLocationNotifier.new),
      ],
      child: MaterialApp.router(routerConfig: _testRouter()),
    );

void main() {
  group('MapExploreScreen', () {
    testWidgets('renders markers for a fetched list mixing both types',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
    });

    testWidgets('grocery marker callout routes to /groceries/<id>',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.eco_outlined));
      await tester.pumpAndSettle();

      expect(find.text('View Details'), findsOneWidget);
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(find.text('GroceryDetail:g1'), findsOneWidget);
    });

    testWidgets('restaurant marker callout routes to /restaurants/<id>',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      expect(find.text('View Details'), findsOneWidget);
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      expect(find.text('RestaurantDetail:r1'), findsOneWidget);
    });

    testWidgets('filter chips narrow the visible marker set',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsNothing);

      await tester.tap(find.text('Restaurants'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.eco_outlined), findsNothing);
    });

    testWidgets('hides the category label in the callout when null',
        (tester) async {
      await tester.pumpWidget(
        _routerWrap(stores: const [_testGroceryNoCategory]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.eco_outlined));
      await tester.pumpAndSettle();

      expect(find.text('No Category Grocer'), findsWidgets);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets(
        'keeps the map visible with no venue markers while the fetch is loading',
        (tester) async {
      // Never-completing future — keeps the fetch in the "loading" state
      // without leaving a real pending Timer behind (unlike Future.delayed).
      final completer = Completer<List<StoreModel>>();
      await tester.pumpWidget(
        _routerWrap(storesBuilder: (_) => completer.future),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsNothing);
      expect(find.byIcon(Icons.eco_outlined), findsNothing);
    });

    testWidgets(
        'shows a non-blocking SnackBar and keeps the map visible on fetch error',
        (tester) async {
      await tester.pumpWidget(
        _routerWrap(storesBuilder: (_) async => throw Exception('network')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsNothing);
      expect(find.byIcon(Icons.eco_outlined), findsNothing);
    });
  });
}
