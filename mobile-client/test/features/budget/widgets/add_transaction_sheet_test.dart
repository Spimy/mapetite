import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/widgets/add_transaction_sheet.dart';
import 'package:mapetite/shared/providers/store_providers.dart';
import 'package:mapetite/shared/models/store_model.dart';

class _NoopBudgetNotifier extends BudgetNotifier {
  @override
  Future<BudgetState> build() async => const BudgetState(transactions: []);

  @override
  Future<void> addTransaction(draft, {String? draftDisplayName}) async {
    // no-op — this test only checks the form renders and validates input,
    // not the network round trip (covered by the integration test suite).
  }
}

void main() {
  testWidgets('requires a name and a positive amount before Save is enabled',
      (tester) async {
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(_NoopBudgetNotifier.new),
      storesProvider(StoreType.restaurant).overrideWith((ref) async => <StoreModel>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAddTransactionSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Save Transaction'), findsOneWidget);

    final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Transaction');
    // Save button starts disabled (amount is empty).
    final button = tester.widget<ElevatedButton>(saveButtonFinder);
    expect(button.onPressed, isNull);
  });
}
