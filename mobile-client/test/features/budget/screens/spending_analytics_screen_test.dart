import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/screens/spending_analytics_screen.dart';

/// Mirrors the pattern in budget_overview_screen_test.dart: a fixed
/// BudgetNotifier override so the provider resolves to known data.
class _FixedBudgetNotifier extends BudgetNotifier {
  final BudgetState _state;
  _FixedBudgetNotifier(this._state);
  @override
  Future<BudgetState> build() async => _state;
}

Widget _wrap(BudgetState state) => ProviderScope(
      overrides: [
        budgetProvider.overrideWith(() => _FixedBudgetNotifier(state)),
      ],
      child: const MaterialApp(home: SpendingAnalyticsScreen()),
    );

BudgetTransaction _tx({
  required BudgetCategory category,
  required double amount,
  required DateTime dateSpent,
}) =>
    BudgetTransaction(
      id: 'tx_${category.name}_${dateSpent.millisecondsSinceEpoch}',
      category: category,
      amount: amount,
      dateSpent: dateSpent,
      createdAt: dateSpent,
    );

void main() {
  testWidgets(
      'Key Discoveries shows a real dining trend, not the old hardcoded 15%',
      (tester) async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 10);
    final lastMonth = DateTime(now.year, now.month - 1, 10);

    final transactions = [
      _tx(category: BudgetCategory.dining, amount: 50, dateSpent: thisMonth),
      _tx(category: BudgetCategory.dining, amount: 100, dateSpent: lastMonth),
    ];

    await tester.pumpWidget(_wrap(BudgetState(
      transactions: transactions,
      dineInBudget: 300,
      groceryBudget: 300,
    )));
    await tester.pumpAndSettle();

    // 50 vs 100 is a real 50% decrease — must not show the old fake "15% less".
    // The insight body is rendered via a standalone RichText, so
    // findRichText: true is required for textContaining to see it.
    expect(
      find.textContaining('15% less', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('50% less', findRichText: true),
      findsWidgets,
    );
    expect(find.text('Dining out decreased'), findsOneWidget);
  });

  testWidgets(
      'Dining insight card is hidden entirely when there is no prior-month spending to compare against',
      (tester) async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 10);

    final transactions = [
      _tx(category: BudgetCategory.dining, amount: 50, dateSpent: thisMonth),
    ];

    await tester.pumpWidget(_wrap(BudgetState(
      transactions: transactions,
      dineInBudget: 300,
      groceryBudget: 300,
    )));
    await tester.pumpAndSettle();

    // No last-month dining data means no legitimate percentage to report —
    // the card must not appear (and must not divide by zero/crash).
    expect(find.text('Dining out decreased'), findsNothing);
    expect(find.text('Dining out increased'), findsNothing);
  });

  testWidgets(
      'Grocery peak insight shows "Weekend Spikes" when peak is on Saturday or Sunday',
      (tester) async {
    final now = DateTime.now();
    // Find a Saturday or Sunday in the current month
    late DateTime saturday;
    for (var day = 1; day <= DateTime(now.year, now.month + 1, 0).day; day++) {
      final date = DateTime(now.year, now.month, day);
      if (date.weekday == 6) {
        saturday = date;
        break;
      }
    }

    // Two grocery transactions 7 days apart on the same weekday (Saturday);
    // a third on a different weekday with a much smaller amount makes
    // the Saturday a clear (>=30% above average) peak.
    final sameWeekday = saturday.add(const Duration(days: 7));
    final otherWeekday = saturday.add(const Duration(days: 2));

    final transactions = [
      _tx(
          category: BudgetCategory.groceries,
          amount: 100,
          dateSpent: saturday),
      _tx(
          category: BudgetCategory.groceries,
          amount: 100,
          dateSpent: sameWeekday),
      _tx(
          category: BudgetCategory.groceries,
          amount: 10,
          dateSpent: otherWeekday),
    ];

    await tester.pumpWidget(_wrap(BudgetState(
      transactions: transactions,
      dineInBudget: 300,
      groceryBudget: 300,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Spikes'), findsOneWidget);
    expect(
      find.textContaining('Saturdays', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets(
      'Grocery peak insight shows "Spending Spikes" when peak is on a weekday (not weekend)',
      (tester) async {
    final now = DateTime.now();
    // Find a Tuesday in the current month
    late DateTime tuesday;
    for (var day = 1; day <= DateTime(now.year, now.month + 1, 0).day; day++) {
      final date = DateTime(now.year, now.month, day);
      if (date.weekday == 2) {
        tuesday = date;
        break;
      }
    }

    // Two grocery transactions 7 days apart on the same weekday (Tuesday);
    // a third on a different weekday with a much smaller amount makes
    // the Tuesday a clear (>=30% above average) peak.
    final sameWeekday = tuesday.add(const Duration(days: 7));
    final otherWeekday = tuesday.add(const Duration(days: 2));

    final transactions = [
      _tx(
          category: BudgetCategory.groceries,
          amount: 100,
          dateSpent: tuesday),
      _tx(
          category: BudgetCategory.groceries,
          amount: 100,
          dateSpent: sameWeekday),
      _tx(
          category: BudgetCategory.groceries,
          amount: 10,
          dateSpent: otherWeekday),
    ];

    await tester.pumpWidget(_wrap(BudgetState(
      transactions: transactions,
      dineInBudget: 300,
      groceryBudget: 300,
    )));
    await tester.pumpAndSettle();

    // Should NOT show "Weekend Spikes" for a non-weekend peak
    expect(find.text('Weekend Spikes'), findsNothing);
    // Should show the generic "Spending Spikes" title instead
    expect(find.text('Spending Spikes'), findsOneWidget);
    // Should still correctly show the actual weekday name in the body
    expect(
      find.textContaining('Tuesdays', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets(
      'Grocery peak insight card is hidden when there are too few transactions to call a real peak',
      (tester) async {
    final now = DateTime.now();
    final transactions = [
      _tx(
          category: BudgetCategory.groceries,
          amount: 40,
          dateSpent: DateTime(now.year, now.month, 3)),
      _tx(
          category: BudgetCategory.groceries,
          amount: 40,
          dateSpent: DateTime(now.year, now.month, 11)),
    ];

    await tester.pumpWidget(_wrap(BudgetState(
      transactions: transactions,
      dineInBudget: 300,
      groceryBudget: 300,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Spikes'), findsNothing);
  });
}
