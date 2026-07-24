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

Future<void> _openSheet(WidgetTester tester, ProviderContainer container) async {
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
}

ProviderContainer _buildContainer({List<StoreModel> stores = const []}) {
  return ProviderContainer(overrides: [
    budgetProvider.overrideWith(_NoopBudgetNotifier.new),
    storesProvider(StoreType.restaurant).overrideWith((ref) async => stores),
  ]);
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
}
