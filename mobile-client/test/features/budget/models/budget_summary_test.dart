import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_summary.dart';

void main() {
  test('BudgetSummary.fromJson maps the real summary API response', () {
    final json = {
      'month': 7,
      'month_name': 'July',
      'month_short': 'Jul',
      'year': 2026,
      'dine_in': {'spent': '15.00', 'budget': '300.00', 'percentage_used': 5.0},
      'grocery': {'spent': '42.50', 'budget': '400.00', 'percentage_used': 10.6},
    };

    final summary = BudgetSummary.fromJson(json);

    expect(summary.month, 7);
    expect(summary.year, 2026);
    expect(summary.dineIn.spent, 15.00);
    expect(summary.dineIn.budget, 300.00);
    expect(summary.dineIn.percentageUsed, 5.0);
    expect(summary.grocery.spent, 42.50);
    expect(summary.grocery.budget, 400.00);
    expect(summary.grocery.percentageUsed, 10.6);
  });
}
