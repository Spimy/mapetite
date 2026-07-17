import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/models/store_item_model.dart';
import 'package:mapetite/shared/utils/pricing_util.dart';
import 'package:mapetite/shared/widgets/pricing_badge.dart';

StoreItemModel _item(double price) => StoreItemModel(
      id: '1',
      name: 'Item',
      description: '',
      price: price,
      stockStatus: 'IN_STOCK',
      category: 'Test',
    );

void main() {
  group('computePricingBracket', () {
    test('empty item list defaults to mid', () {
      expect(computePricingBracket([]), PricingBracket.mid);
    });

    test('average price under RM10 is budget', () {
      expect(computePricingBracket([_item(5), _item(7)]), PricingBracket.budget);
    });

    test('average price between RM10 and RM20 is mid', () {
      expect(computePricingBracket([_item(12), _item(18)]), PricingBracket.mid);
    });

    test('average price RM20 and above is premium', () {
      expect(computePricingBracket([_item(25), _item(30)]), PricingBracket.premium);
    });
  });
}
