import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints budget routes', () {
    test('budget points at the real spending-records list route', () {
      expect(ApiEndpoints.budget, 'spending-records/');
    });

    test('budgetDetail builds the per-record route', () {
      expect(ApiEndpoints.budgetDetail('7'), 'spending-records/7/');
    });

    test('budgetSummary points at the real summary route', () {
      expect(ApiEndpoints.budgetSummary, 'spending-records/summary/');
    });
  });
}
