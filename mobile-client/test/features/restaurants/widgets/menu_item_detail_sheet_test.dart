import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/restaurants/widgets/menu_item_detail_sheet.dart';
import 'package:mapetite/shared/models/store_item_model.dart';

void main() {
  testWidgets('renders StoreItemModel fields', (tester) async {
    const item = StoreItemModel(
      id: '1',
      name: 'Nasi Lemak',
      description: 'Coconut rice with sambal and anchovies.',
      price: 8.50,
      thumbnailUrl: null,
      stockStatus: 'IN_STOCK',
      category: 'Mains',
      dietaryTags: ['Halal'],
      restrictions: ['Nuts'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MenuItemDetailSheet(item: item)),
      ),
    );

    expect(find.text('Nasi Lemak'), findsOneWidget);
    expect(find.text('Coconut rice with sambal and anchovies.'), findsOneWidget);
    expect(find.textContaining('8.50'), findsOneWidget);
  });
}
