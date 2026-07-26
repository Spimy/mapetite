import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/widgets/transaction_detail_sheet.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';

class _NoopBudgetNotifier extends BudgetNotifier {
  @override
  Future<BudgetState> build() async => const BudgetState(transactions: []);
}

final _tx = BudgetTransaction(
  id: 'tx1',
  storeId: '1',
  storeName: 'Jaya Grocer',
  category: BudgetCategory.groceries,
  amount: 42.50,
  dateSpent: DateTime(2026, 7, 20),
  createdAt: DateTime(2026, 7, 20),
);

Future<void> _openDetailSheet(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showTransactionDetailSheet(context, _tx),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping Edit closes the detail sheet and opens the add/edit sheet pre-filled',
      (tester) async {
    final container = ProviderContainer(overrides: [
      budgetProvider.overrideWith(_NoopBudgetNotifier.new),
      storesProvider(StoreType.grocery).overrideWith((ref) async => []),
    ]);
    addTearDown(container.dispose);

    await _openDetailSheet(tester, container);

    expect(find.text('Jaya Grocer'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Edit'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit'));
    await tester.pumpAndSettle();

    // Detail sheet is gone, add/edit sheet is open in edit mode, pre-filled.
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Save Changes'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
  });
}
