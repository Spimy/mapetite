import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('shows an empty state on error', (tester) async {
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

  testWidgets('shows empty state when no stores are returned', (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryListingScreen(),
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => <StoreModel>[]),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('No grocery stores found'), findsOneWidget);
  });
}
