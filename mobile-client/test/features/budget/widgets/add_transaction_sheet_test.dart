import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_state.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/providers/budget_provider.dart';
import 'package:mapetite/features/budget/widgets/add_transaction_sheet.dart';
import 'package:mapetite/shared/providers/store_providers.dart';
import 'package:mapetite/shared/models/store_model.dart';

class _NoopBudgetNotifier extends BudgetNotifier {
  bool addCalled = false;
  bool deleteCalled = false;
  String? editedId;
  BudgetTransactionDraft? editedDraft;

  @override
  Future<BudgetState> build() async => const BudgetState(transactions: []);

  @override
  Future<void> addTransaction(draft, {String? draftDisplayName}) async {
    // no-op — this test only checks the form renders and validates input,
    // not the network round trip (covered by the integration test suite).
    addCalled = true;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deleteCalled = true;
  }

  @override
  Future<void> editTransaction(
    String id,
    BudgetTransactionDraft draft, {
    String? draftDisplayName,
  }) async {
    editedId = id;
    editedDraft = draft;
  }
}

final _fakeStores = <StoreModel>[
  const StoreModel(
    id: '1',
    businessName: 'Jaya Grocer',
    description: 'A grocer',
    merchantType: StoreType.restaurant,
    halal: true,
    vegan: false,
    streetAddress: '123 Main St',
  ),
  const StoreModel(
    id: '2',
    businessName: 'Nasi Lemak Corner',
    description: 'A restaurant',
    merchantType: StoreType.restaurant,
    halal: true,
    vegan: false,
    streetAddress: '456 Second St',
  ),
];

Future<void> _openSheet(
  WidgetTester tester,
  ProviderContainer container, {
  BudgetTransaction? existing,
}) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAddTransactionSheet(context, existing: existing),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

ProviderContainer _buildContainer({List<StoreModel> stores = const []}) {
  return ProviderContainer(overrides: [
    budgetProvider.overrideWith(_NoopBudgetNotifier.new),
    storesProvider(StoreType.restaurant).overrideWith((ref) async => stores),
  ]);
}

({ProviderContainer container, _NoopBudgetNotifier notifier})
    _buildContainerWithNotifier({List<StoreModel> stores = const []}) {
  final notifier = _NoopBudgetNotifier();
  final container = ProviderContainer(overrides: [
    budgetProvider.overrideWith(() => notifier),
    storesProvider(StoreType.restaurant).overrideWith((ref) async => stores),
  ]);
  return (container: container, notifier: notifier);
}

// The amount field is a raw TextField; the name field ("Item / Place") is
// the sheet's only AppTextField, which is backed by a TextFormField.
Finder get _amountFieldFinder => find.byType(TextField).first;
Finder get _nameFieldFinder => find.byType(TextFormField);
Finder get _saveButtonFinder =>
    find.widgetWithText(ElevatedButton, 'Save Transaction');

void main() {
  testWidgets('requires a name and a positive amount before Save is enabled',
      (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await _openSheet(tester, container);

    expect(find.text('Save Transaction'), findsOneWidget);

    // Save button starts disabled (amount is empty).
    final button = tester.widget<ElevatedButton>(_saveButtonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('entering only an amount keeps Save disabled', (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await _openSheet(tester, container);

    await tester.enterText(_amountFieldFinder, '25.50');
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(_saveButtonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('entering only a name keeps Save disabled', (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await _openSheet(tester, container);

    await tester.enterText(_nameFieldFinder, 'Mamak Corner');
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(_saveButtonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('entering both a valid name and amount enables Save',
      (tester) async {
    final container = _buildContainer();
    addTearDown(container.dispose);

    await _openSheet(tester, container);

    await tester.enterText(_amountFieldFinder, '25.50');
    await tester.enterText(_nameFieldFinder, 'Mamak Corner');
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(_saveButtonFinder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
      'tapping the store picker opens a sheet and selecting a store fills the name field',
      (tester) async {
    final container = _buildContainer(stores: _fakeStores);
    addTearDown(container.dispose);

    await _openSheet(tester, container);

    await tester.tap(find.text('Link a store (optional)'));
    await tester.pumpAndSettle();

    expect(find.text('Select a store'), findsOneWidget);
    expect(find.text('Jaya Grocer'), findsOneWidget);
    expect(find.text('Nasi Lemak Corner'), findsOneWidget);

    await tester.tap(find.text('Jaya Grocer'));
    await tester.pumpAndSettle();

    final nameField = tester.widget<TextFormField>(_nameFieldFinder);
    expect(nameField.controller?.text, 'Jaya Grocer');
  });

  testWidgets(
      'saving an edit calls editTransaction, never delete+add',
      (tester) async {
    final built = _buildContainerWithNotifier();
    addTearDown(built.container.dispose);

    final existing = BudgetTransaction(
      id: 'tx1',
      storeId: '1',
      storeName: 'Jaya Grocer',
      category: BudgetCategory.groceries,
      amount: 25.50,
      dateSpent: DateTime(2026, 7, 20),
      createdAt: DateTime(2026, 7, 20),
    );

    await _openSheet(tester, built.container, existing: existing);

    final saveButton = find.widgetWithText(ElevatedButton, 'Save Changes');
    expect(saveButton, findsOneWidget);

    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(built.notifier.editedId, 'tx1');
    expect(built.notifier.editedDraft, isNotNull);
    expect(built.notifier.addCalled, isFalse);
    expect(built.notifier.deleteCalled, isFalse);
  });
}
