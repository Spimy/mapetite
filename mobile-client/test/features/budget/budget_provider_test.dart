import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';

BudgetTransaction _tx(String id, BudgetCategory cat, double amt, DateTime dt) =>
    BudgetTransaction(id: id, category: cat, name: 'X', amount: amt, dateTime: dt);

void main() {
  final now = DateTime.now();

  group('BudgetState', () {
    test('totalSpent sums only current-month transactions', () {
      final state = BudgetState(
        transactions: [
          _tx('a', BudgetCategory.groceries, 50.0, now),
          _tx('b', BudgetCategory.dining, 30.0, now),
          _tx('c', BudgetCategory.groceries, 100.0,
              DateTime(now.year, now.month - 1, 1)),
        ],
        monthlyBudget: 600,
        groceriesBudget: 300,
        diningBudget: 200,
      );
      expect(state.totalSpent, 80.0);
      expect(state.groceriesSpent, 50.0);
      expect(state.diningSpent, 30.0);
    });

    test('recentTransactions returns 3 newest sorted desc', () {
      // Use hours so all 5 stay within the current month.
      final txs = List.generate(
        5,
        (i) => _tx('$i', BudgetCategory.groceries, 10.0,
            now.subtract(Duration(hours: i * 2))),
      );
      final state = BudgetState(
          transactions: txs,
          monthlyBudget: 600,
          groceriesBudget: 300,
          diningBudget: 200);
      expect(state.recentTransactions.length, 3);
      expect(state.recentTransactions.first.id, '0');
    });
  });

  group('BudgetNotifier', () {
    ProviderContainer make() => ProviderContainer();

    test('addTransaction prepends to list', () {
      final c = make();
      addTearDown(c.dispose);
      final before = c.read(budgetProvider).transactions.length;
      c.read(budgetProvider.notifier).addTransaction(
            BudgetTransaction(
              id: 'new',
              category: BudgetCategory.dining,
              name: 'Test',
              amount: 5.0,
              dateTime: DateTime.now(),
            ),
          );
      expect(c.read(budgetProvider).transactions.length, before + 1);
      expect(c.read(budgetProvider).transactions.first.id, 'new');
    });

    test('deleteTransaction removes by id', () {
      final c = make();
      addTearDown(c.dispose);
      final id = c.read(budgetProvider).transactions.first.id;
      c.read(budgetProvider.notifier).deleteTransaction(id);
      expect(c.read(budgetProvider).transactions.any((t) => t.id == id), false);
    });

    test('adjustBudget updates all limits', () {
      final c = make();
      addTearDown(c.dispose);
      c.read(budgetProvider.notifier).adjustBudget(
            monthly: 1200,
            groceries: 500,
            dining: 400,
          );
      final s = c.read(budgetProvider);
      expect(s.monthlyBudget, 1200.0);
      expect(s.groceriesBudget, 500.0);
      expect(s.diningBudget, 400.0);
    });
  });
}
