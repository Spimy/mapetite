import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/models/store_item_model.dart';

void main() {
  group('StoreItemModel.fromJson', () {
    test('maps the real store-items API response shape', () {
      final json = {
        'id': 629,
        'name': 'Baby Carrots (100 g)',
        'description': 'Baby carrots suitable for salads or cooked meals.',
        'price': '2.90',
        'calories': 20,
        'category': 'Vegetables',
        'stock_status': 'IN_STOCK',
        'vegetarian': true,
        'organic': true,
        'gluten_free': true,
        'dairy_free': true,
        'contains_nuts': false,
        'eco_packaging': true,
        'locally_sourced': true,
        'thumbnail': 'http://127.0.0.1:8000/media/merchants/items/23_629.png',
      };

      final item = StoreItemModel.fromJson(json);

      expect(item.id, '629');
      expect(item.name, 'Baby Carrots (100 g)');
      expect(item.price, 2.90);
      expect(item.category, 'Vegetables');
      expect(item.stockStatus, 'IN_STOCK');
      expect(item.thumbnailUrl, 'http://127.0.0.1:8000/media/merchants/items/23_629.png');
      expect(item.unitSize, isNull);
      expect(item.dietaryTags, containsAll(['Vegetarian', 'Organic', 'Gluten Free', 'Dairy Free']));
      expect(item.restrictions, isEmpty);
    });

    test('an item that is not gluten/dairy free surfaces those as restrictions', () {
      final json = {
        'id': 1,
        'name': 'Roti Canai',
        'description': '',
        'price': '1.50',
        'category': 'Mains',
        'stock_status': 'IN_STOCK',
        'vegetarian': false,
        'organic': false,
        'gluten_free': false,
        'dairy_free': false,
        'contains_nuts': true,
      };

      final item = StoreItemModel.fromJson(json);

      expect(item.restrictions, containsAll(['Nuts', 'Gluten', 'Dairy']));
      expect(item.dietaryTags, isEmpty);
    });

    test('missing category falls back to Uncategorised', () {
      final json = {
        'id': 1,
        'name': 'Mystery Item',
        'description': '',
        'price': '0',
        'stock_status': 'IN_STOCK',
      };

      final item = StoreItemModel.fromJson(json);

      expect(item.category, 'Uncategorised');
    });
  });
}
