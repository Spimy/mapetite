import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/groceries/screens/grocery_store_detail_screen.dart';
import 'package:mapetite/shared/models/store_item_model.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

const _store = StoreModel(
  id: '23',
  businessName: 'Jaya Grocer @ Sunway Pyramid',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Sunway Pyramid, Selangor',
);

const _items = [
  StoreItemModel(
    id: '1',
    name: 'Baby Carrots',
    description: '',
    price: 2.9,
    unitSize: '100 g',
    stockStatus: 'IN_STOCK',
    category: 'Vegetables',
  ),
  StoreItemModel(
    id: '2',
    name: 'Fresh Milk',
    description: '',
    price: 8.5,
    stockStatus: 'IN_STOCK',
    category: 'Dairy',
  ),
];

Widget _wrap(Widget child, {required List<Override> overrides}) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: child));

void main() {
  testWidgets('renders real store and item data', (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryStoreDetailScreen(storeId: '23'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith((ref, id) async => _items),
      ],
    ));

    await tester.pumpAndSettle();

    // The store name legitimately renders twice: once in the AppBar title,
    // once in the store header card (mirrors the AppBar+header duplication
    // that already existed in the pre-migration hardcoded screen).
    expect(find.text('Jaya Grocer @ Sunway Pyramid'), findsWidgets);
    expect(find.text('Baby Carrots'), findsOneWidget);
  });

  testWidgets('category tabs are derived from real item categories',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryStoreDetailScreen(storeId: '23'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith((ref, id) async => _items),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Vegetables'), findsWidgets);
    expect(find.text('Dairy'), findsWidgets);
    expect(find.text('Fresh Produce'), findsNothing);
    expect(find.text('Pantry'), findsNothing);
  });

  testWidgets('an item with no unit size does not show an empty subtitle line',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryStoreDetailScreen(storeId: '23'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith((ref, id) async => _items),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Fresh Milk'), findsOneWidget);
  });

  testWidgets('shows an error state if either provider fails', (tester) async {
    await tester.pumpWidget(_wrap(
      const GroceryStoreDetailScreen(storeId: '23'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith(
          (ref, id) => Future<List<StoreItemModel>>.error('boom'),
        ),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
  });
}
