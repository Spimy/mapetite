import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';

BudgetTransaction _tx(String id, double amount) => BudgetTransaction(
      id: id,
      category: BudgetCategory.dining,
      amount: amount,
      dateSpent: DateTime(2026, 7, 20),
      createdAt: DateTime(2026, 7, 20),
    );

class _FakeBudgetNotifier extends BudgetNotifier {
  final BudgetState _initial;
  _FakeBudgetNotifier(this._initial);

  @override
  Future<BudgetState> build() async => _initial;
}

void main() {
  test('build() surfaces the initial state as data', () async {
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(() => _FakeBudgetNotifier(
            BudgetState(transactions: [_tx('a', 10)], dineInBudget: 300, groceryBudget: 300),
          )),
    ]);
    addTearDown(container.dispose);

    final state = await container.read(budgetProvider.future);

    expect(state.transactions.single.id, 'a');
    expect(state.monthlyBudget, 600);
  });

  test('deleteTransaction removes the transaction from local state before the API call resolves',
      () async {
    // The fake notifier's build() never talks to the network, and its
    // addTransaction/deleteTransaction inherit the real BudgetNotifier
    // implementation, which does call BudgetService — so this test only
    // exercises the synchronous optimistic-update half, not the network
    // round trip (that's covered by the integration test in Task 5).
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(() => _FakeBudgetNotifier(
            BudgetState(transactions: [_tx('a', 10), _tx('b', 20)]),
          )),
    ]);
    addTearDown(container.dispose);
    await container.read(budgetProvider.future);

    final future =
        container.read(budgetProvider.notifier).deleteTransaction('a');

    // deleteTransaction now starts with `await future` (so it also works
    // correctly if called before build() has resolved) — even though
    // `future` is already complete here, `await` always yields at least one
    // microtask before resuming, so give the event loop a tick before the
    // optimistic update has definitely landed in state.
    await Future<void>.delayed(Duration.zero);
    final optimistic = container.read(budgetProvider).value!;
    expect(optimistic.transactions.any((t) => t.id == 'a'), isFalse);

    // The underlying network call will fail (no backend reachable from a
    // fake notifier's real BudgetService in this unit test), so state should
    // roll back to the original two transactions.
    await future.catchError((_) {});
    final rolledBack = container.read(budgetProvider).value!;
    expect(rolledBack.transactions.length, 2);
  });
}
