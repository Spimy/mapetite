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

const _weekdayNames = [
  'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays',
  'Fridays', 'Saturdays', 'Sundays',
];

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
      'Grocery peak insight names the real peak weekday, not the old hardcoded Saturdays',
      (tester) async {
    final now = DateTime.now();
    // Two grocery transactions 7 days apart share a weekday; a third on a
    // different weekday for a much smaller amount makes the shared weekday
    // a clear (>=30% above average) peak.
    final anchor = DateTime(now.year, now.month, 10);
    final sameWeekday = anchor.add(const Duration(days: 7));
    final otherWeekday = anchor.add(const Duration(days: 2));

    final transactions = [
      _tx(category: BudgetCategory.groceries, amount: 100, dateSpent: anchor),
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

    final expectedLabel = _weekdayNames[anchor.weekday - 1];
    expect(find.text('Weekend Spikes'), findsOneWidget);
    expect(
      find.textContaining(expectedLabel, findRichText: true),
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
