import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/profile/models/profile_setup_data.dart';

void main() {
  test('monthlyBudget is computed from dineInBudget + groceryBudget', () {
    const data = ProfileSetupData(dineInBudget: 300, groceryBudget: 200);
    expect(data.monthlyBudget, 500);
  });

  test('copyWith overrides only the given budget fields', () {
    const data = ProfileSetupData(dineInBudget: 300, groceryBudget: 200);
    final updated = data.copyWith(dineInBudget: 350);
    expect(updated.dineInBudget, 350);
    expect(updated.groceryBudget, 200);
  });
}
