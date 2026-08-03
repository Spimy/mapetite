import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/features/groceries/screens/grocery_listing_screen.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

final _storeA = const StoreModel(
  id: '23',
  businessName: 'Jaya Grocer @ Sunway Pyramid',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Sunway Pyramid',
  distanceKm: 1.2,
);

Widget _wrap(Widget child, {required List<Override> overrides}) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: child));

void main() {
  testWidgets('shows the generic error state for a non-network error',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryListingScreen(),
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
      const GroceryListingScreen(),
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

  testWidgets('renders real grocery store data from the provider',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Jaya Grocer @ Sunway Pyramid'), findsOneWidget);
  });

  testWidgets(
      'shows a "nothing nearby" empty state with Try Again when no stores are returned',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => <StoreModel>[]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nothing nearby.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets(
      'shows "No grocery stores found" with Clear Filters when a search narrows non-empty results to zero',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA]),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pumpAndSettle();

    expect(find.text('No grocery stores found'), findsOneWidget);
    expect(find.text('Clear Filters'), findsOneWidget);
  });

  testWidgets('does not show Halal/Vegan quick filters or a Dietary filter section', (tester) async {
    await tester.pumpWidget(_wrap(const GroceryListingScreen(), overrides: [
      nearbyStoresProvider.overrideWith((ref, query) async => [_storeA]),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Halal'), findsNothing);
    expect(find.text('Vegan'), findsNothing);
    expect(find.text('Open Now'), findsOneWidget);
    expect(find.text('Nearby < 1km'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter Grocery Stores'), findsOneWidget);
    expect(find.text('Dietary'), findsNothing);
    expect(find.text('Distance'), findsOneWidget);
  });
}
