import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_summary.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/screens/budget_overview_screen.dart';
import 'package:mapetite/shared/widgets/loading_indicator.dart';

class _FixedBudgetNotifier extends BudgetNotifier {
  final BudgetState _state;
  _FixedBudgetNotifier(this._state);
  @override
  Future<BudgetState> build() async => _state;
}

/// Never resolves, so the provider stays in the "loading" state for the
/// duration of the test — avoids relying on precisely-timed manual state
/// overrides, which race against the framework's own AsyncLoading/AsyncData
/// transition (see restaurant_listing_screen_test.dart for the same pattern).
class _PendingBudgetNotifier extends BudgetNotifier {
  @override
  Future<BudgetState> build() => Completer<BudgetState>().future;
}

Widget _wrap(BudgetState state) => ProviderScope(
      overrides: [
        budgetProvider.overrideWith(() => _FixedBudgetNotifier(state)),
      ],
      child: const MaterialApp(home: BudgetOverviewScreen()),
    );

void main() {
  testWidgets(
      'Categories card progress bars use the real dine-in/grocery budgets, not the old hardcoded 200/300',
      (tester) async {
    // dineInBudget=555 with 111 spent -> ratio 0.2. The old hardcoded bug
    // divided by a fixed 200.0 instead, which would give 0.555 here — a
    // clearly different, wrong value.
    await tester.pumpWidget(_wrap(const BudgetState(
      transactions: [],
      dineInBudget: 555,
      groceryBudget: 777,
      summary: BudgetSummary(
        month: 7,
        year: 2026,
        dineIn: BudgetCategorySummary(spent: 111, budget: 555, percentageUsed: 20),
        grocery: BudgetCategorySummary(spent: 0, budget: 777, percentageUsed: 0),
      ),
    )));
    await tester.pumpAndSettle();

    final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect(bars.first.value, closeTo(111 / 555, 0.001));
  });

  testWidgets('shows a shimmer skeleton while budgetProvider is loading',
      (tester) async {
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(_PendingBudgetNotifier.new),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: BudgetOverviewScreen()),
    ));
    await tester.pump();

    expect(find.byType(ShimmerLoader), findsOneWidget);
    expect(find.byType(CardShimmer), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
