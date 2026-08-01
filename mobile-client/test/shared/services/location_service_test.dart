import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/services/location_service.dart';

void main() {
  group('cityFromPhotonProperties (pure parsing, no network)', () {
    test('prefers city over district for a clean, recognizable name', () {
      final result = cityFromPhotonProperties({
        'name': 'Persiaran Bakti',
        'district': 'UEP Subang Jaya',
        'city': 'Subang Jaya',
        'county': 'Petaling',
        'state': 'Selangor',
      });
      expect(result, 'Subang Jaya');
    });

    test('falls back to district when city is missing', () {
      final result = cityFromPhotonProperties({
        'district': 'Bangsar',
        'state': 'Selangor',
      });
      expect(result, 'Bangsar');
    });

    test('falls back to state when nothing finer is available', () {
      final result = cityFromPhotonProperties({'state': 'Selangor'});
      expect(result, 'Selangor');
    });

    test('returns null when properties has no usable location field', () {
      final result = cityFromPhotonProperties({'country': 'Malaysia'});
      expect(result, isNull);
    });
  });
}
