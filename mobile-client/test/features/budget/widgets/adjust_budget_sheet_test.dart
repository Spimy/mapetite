import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/widgets/adjust_budget_sheet.dart';

class _FixedBudgetNotifier extends BudgetNotifier {
  bool adjustCalled = false;
  @override
  Future<BudgetState> build() async =>
      const BudgetState(transactions: [], dineInBudget: 300, groceryBudget: 300);

  @override
  Future<void> adjustBudget({double? dineIn, double? grocery, int? alertPercent}) async {
    adjustCalled = true;
  }
}

void main() {
  testWidgets('pre-fills dine-in and grocery budget fields from provider state',
      (tester) async {
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(_FixedBudgetNotifier.new),
    ]);
    addTearDown(container.dispose);
    await container.read(budgetProvider.future);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAdjustBudgetSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Dine-In Budget'), findsOneWidget);
    expect(find.text('Groceries Budget'), findsOneWidget);
    expect(find.widgetWithText(TextField, '300'), findsWidgets);
  });
}
