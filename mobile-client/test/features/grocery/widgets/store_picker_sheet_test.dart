import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/grocery/widgets/store_picker_sheet.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

const _storeA = StoreModel(
  id: '1',
  businessName: 'Jaya Grocer @ Sunway Pyramid',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: '',
  latitude: 3.0733,
  longitude: 101.6067,
);

const _storeB = StoreModel(
  id: '2',
  businessName: 'Village Grocer Bangsar',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: '',
  latitude: 3.1319,
  longitude: 101.6841,
);

void main() {
  testWidgets('lists nearby grocery stores and returns the tapped one', (tester) async {
    StoreModel? picked;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA, _storeB]),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              picked = await showModalBottomSheet<StoreModel>(
                context: context,
                builder: (_) => const StorePickerSheet(),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Jaya Grocer @ Sunway Pyramid'), findsOneWidget);
    expect(find.text('Village Grocer Bangsar'), findsOneWidget);

    await tester.tap(find.text('Village Grocer Bangsar'));
    await tester.pumpAndSettle();

    expect(picked?.id, '2');
  });

  testWidgets('typing filters the store list by name', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        nearbyStoresProvider.overrideWith((ref, query) async => [_storeA, _storeB]),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet<StoreModel>(
              context: context,
              builder: (_) => const StorePickerSheet(),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Village');
    await tester.pumpAndSettle();

    expect(find.text('Village Grocer Bangsar'), findsOneWidget);
    expect(find.text('Jaya Grocer @ Sunway Pyramid'), findsNothing);
  });
}
