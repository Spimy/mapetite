import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/utils/validators.dart';

void main() {
  group('Validators.username', () {
    test('requires a username', () {
      expect(Validators.username(''), 'Username is required.');
    });

    test('rejects usernames shorter than 3 characters', () {
      expect(
        Validators.username('ab'),
        'Username must be at least 3 characters.',
      );
    });

    test('rejects spaces and symbols', () {
      expect(
        Validators.username('rohan kaghan'),
        'Username can only contain letters and numbers.',
      );

      expect(
        Validators.username('rohan@123'),
        'Username can only contain letters and numbers.',
      );
    });

    test('accepts a valid username', () {
      expect(Validators.username('rohan123'), isNull);
    });
  });
}