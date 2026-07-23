import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_summary.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';

BudgetTransaction _tx(String id, BudgetCategory cat, double amt, DateTime dt) =>
    BudgetTransaction(
      id: id,
      category: cat,
      amount: amt,
      dateSpent: dt,
      createdAt: dt,
    );

void main() {
  group('BudgetState', () {
    test('monthlyBudget is the sum of dineInBudget and groceryBudget', () {
      const state = BudgetState(
        transactions: [],
        dineInBudget: 300,
        groceryBudget: 400,
      );
      expect(state.monthlyBudget, 700);
    });

    test('totalSpent/diningSpent/groceriesSpent come from the summary, not transactions', () {
      final state = BudgetState(
        transactions: [_tx('a', BudgetCategory.dining, 999, DateTime(2026, 1, 1))],
        summary: const BudgetSummary(
          month: 7,
          year: 2026,
          dineIn: BudgetCategorySummary(spent: 15, budget: 300, percentageUsed: 5),
          grocery: BudgetCategorySummary(spent: 42.5, budget: 400, percentageUsed: 10.6),
        ),
      );
      expect(state.diningSpent, 15);
      expect(state.groceriesSpent, 42.5);
      expect(state.totalSpent, 57.5);
    });

    test('totalSpent is 0 when summary has not loaded yet', () {
      const state = BudgetState(transactions: []);
      expect(state.totalSpent, 0);
    });

    test('recentTransactions returns the 3 newest by dateSpent', () {
      final txs = List.generate(
        5,
        (i) => _tx('$i', BudgetCategory.groceries, 10.0,
            DateTime(2026, 7, 20).subtract(Duration(days: i))),
      );
      final state = BudgetState(transactions: txs);
      expect(state.recentTransactions.length, 3);
      expect(state.recentTransactions.first.id, '0');
    });

    test('copyWith overrides only the given fields', () {
      const state = BudgetState(transactions: [], dineInBudget: 100, groceryBudget: 200);
      final updated = state.copyWith(dineInBudget: 150);
      expect(updated.dineInBudget, 150);
      expect(updated.groceryBudget, 200);
    });
  });
}
