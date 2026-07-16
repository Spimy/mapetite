import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/models/store_model.dart';

void main() {
  group('StoreType', () {
    test('apiValue round-trips through fromApiValue', () {
      expect(StoreType.fromApiValue('RESTAURANT'), StoreType.restaurant);
      expect(StoreType.fromApiValue('GROCERY'), StoreType.grocery);
      expect(StoreType.restaurant.apiValue, 'RESTAURANT');
      expect(StoreType.grocery.apiValue, 'GROCERY');
    });
  });

  group('StoreModel.fromJson', () {
    test('maps the real nearby-stores API response shape', () {
      final json = {
        'id': 23,
        'business_name': 'Jaya Grocer @ Sunway Pyramid',
        'description': 'The signature store of a grocery store chain.',
        'merchant_type': 'GROCERY',
        'halal': false,
        'vegan': false,
        'street_address': 'LG2-130, Sunway Pyramid, Selangor',
        'image_url': 'http://127.0.0.1:8000/media/merchants/stores/23.png',
        'operating_hours': [
          {
            'day_of_week': 0,
            'day_name': 'Monday',
            'open_time': '09:30:00',
            'close_time': '22:00:00',
            'is_closed': false,
          },
        ],
        'latitude': 3.0733,
        'longitude': 101.6067,
        'distance_km': 1.42,
      };

      final store = StoreModel.fromJson(json);

      expect(store.id, '23');
      expect(store.businessName, 'Jaya Grocer @ Sunway Pyramid');
      expect(store.merchantType, StoreType.grocery);
      expect(store.halal, isFalse);
      expect(store.streetAddress, 'LG2-130, Sunway Pyramid, Selangor');
      expect(store.imageUrl, 'http://127.0.0.1:8000/media/merchants/stores/23.png');
      expect(store.operatingHours, hasLength(1));
      expect(store.latitude, 3.0733);
      expect(store.distanceKm, 1.42);
      expect(store.phone, isNull);
      expect(store.category, isNull);
    });

    test('handles a store-detail response with no distance_km field', () {
      final json = {
        'id': 5,
        'business_name': 'Nasi Kandar Ali',
        'description': '',
        'merchant_type': 'RESTAURANT',
        'halal': true,
        'vegan': false,
        'street_address': '',
        'image_url': null,
        'operating_hours': <Map<String, dynamic>>[],
      };

      final store = StoreModel.fromJson(json);

      expect(store.distanceKm, isNull);
      expect(store.imageUrl, isNull);
    });
  });

  group('StoreModel computed getters', () {
    test('walkMinutesEstimate is null without a distance', () {
      const store = StoreModel(
        id: '1',
        businessName: 'Test',
        description: '',
        merchantType: StoreType.restaurant,
        halal: false,
        vegan: false,
        streetAddress: '',
      );
      expect(store.walkMinutesEstimate, isNull);
    });

    test('walkMinutesEstimate is computed from distanceKm at a fixed walking pace', () {
      const store = StoreModel(
        id: '1',
        businessName: 'Test',
        description: '',
        merchantType: StoreType.restaurant,
        halal: false,
        vegan: false,
        streetAddress: '',
        distanceKm: 1.0,
      );
      expect(store.walkMinutesEstimate, 12);
    });

    test('dietaryTags is empty when neither halal nor vegan', () {
      const store = StoreModel(
        id: '1',
        businessName: 'Test',
        description: '',
        merchantType: StoreType.restaurant,
        halal: false,
        vegan: false,
        streetAddress: '',
      );
      expect(store.dietaryTags, isEmpty);
    });

    test('dietaryTags contains Halal and Vegan when both flags are true', () {
      const store = StoreModel(
        id: '1',
        businessName: 'Test',
        description: '',
        merchantType: StoreType.restaurant,
        halal: true,
        vegan: true,
        streetAddress: '',
      );
      expect(store.dietaryTags, containsAll(['Halal', 'Vegan']));
      expect(store.dietaryTags, hasLength(2));
    });

    test('dietaryTags contains only Halal when vegan is false', () {
      const store = StoreModel(
        id: '1',
        businessName: 'Test',
        description: '',
        merchantType: StoreType.restaurant,
        halal: true,
        vegan: false,
        streetAddress: '',
      );
      expect(store.dietaryTags, ['Halal']);
    });
  });
}
