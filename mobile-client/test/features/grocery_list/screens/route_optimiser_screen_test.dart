import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/grocery/models/grocery_list_model.dart';
import 'package:mapetite/features/grocery/providers/grocery_list_provider.dart';
import 'package:mapetite/features/grocery_list/screens/route_optimiser_screen.dart';
import 'package:mapetite/shared/models/location_model.dart';
import 'package:mapetite/shared/providers/location_provider.dart';

const _userLocation = LocationModel(latitude: 3.0731, longitude: 101.6069, city: 'Subang Jaya');

final _items = [
  const GroceryListItem(
    id: '1',
    name: 'Cooked rice',
    quantity: '1',
    storeName: 'Jaya Grocer',
    storeId: 'store1',
    storeLatitude: 3.0733,
    storeLongitude: 101.6067,
    estimatedPrice: 5,
  ),
  const GroceryListItem(
    id: '2',
    name: 'Old free-text item with no linked store',
    quantity: '1',
    storeName: 'Some Random Shop',
    estimatedPrice: 3,
  ),
];

void main() {
  testWidgets('groups items by real linked store and shows unassigned items separately', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        groceryListProvider.overrideWith((ref) => GroceryListNotifier()..addFromList(_items)),
        locationProvider.overrideWith(() => _FakeLocationNotifier(_userLocation)),
      ],
      child: const MaterialApp(home: RouteOptimiserScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Jaya Grocer'), findsOneWidget);
    expect(find.textContaining('Unassigned'), findsOneWidget);
    expect(find.text('Some Random Shop'), findsOneWidget);
    // The old hardcoded fake stops must be gone.
    expect(find.text('Village Grocer'), findsNothing);
    expect(find.text('22 min'), findsNothing);
  });
}

class _FakeLocationNotifier extends LocationNotifier {
  final LocationModel? _initial;
  _FakeLocationNotifier(this._initial);

  @override
  Future<LocationModel?> build() async => _initial;
}
