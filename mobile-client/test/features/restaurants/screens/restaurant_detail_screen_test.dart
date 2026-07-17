import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/utils/opening_hours_util.dart';
import 'package:mapetite/features/restaurants/screens/restaurant_detail_screen.dart';
import 'package:mapetite/shared/models/store_item_model.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

final _store = StoreModel(
  id: '1',
  businessName: 'Nasi Kandar Ali',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
  phone: null,
  category: null,
  operatingHours: [
    OperatingHourModel(
      dayOfWeek: DateTime.now().weekday - 1,
      isClosed: false,
      openTime: '00:00:00',
      closeTime: '23:59:00',
    ),
  ],
);

const _items = [
  StoreItemModel(
    id: '1',
    name: 'Nasi Lemak',
    description: 'Coconut rice.',
    price: 8.5,
    stockStatus: 'IN_STOCK',
    category: 'Mains',
  ),
  StoreItemModel(
    id: '2',
    name: 'Teh Tarik',
    description: 'Pulled tea.',
    price: 3.0,
    stockStatus: 'IN_STOCK',
    category: 'Beverage',
  ),
];

Widget _wrap(Widget child, {required List<Override> overrides}) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: child));

void main() {
  testWidgets('renders real store and item data', (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantDetailScreen(restaurantId: '1'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith((ref, id) async => _items),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nasi Kandar Ali'), findsOneWidget);
    expect(find.text('Nasi Lemak'), findsOneWidget);
  });

  testWidgets('menu tabs are derived from real item categories',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantDetailScreen(restaurantId: '1'),
      overrides: [
        storeDetailProvider.overrideWith((ref, id) async => _store),
        storeItemsProvider.overrideWith((ref, id) async => _items),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Mains'), findsOneWidget);
    expect(find.text('Beverage'), findsOneWidget);
    expect(find.text('Sides'), findsNothing);
  });

  testWidgets('shows an error state if either provider fails',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const RestaurantDetailScreen(restaurantId: '1'),
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
