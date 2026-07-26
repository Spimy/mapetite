import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';

void main() {
  group('BudgetCategory', () {
    test('apiValue round-trips through fromApiValue', () {
      for (final cat in BudgetCategory.values) {
        expect(BudgetCategoryX.fromApiValue(cat.apiValue), cat);
      }
    });

    test('apiValue matches backend spending_type choices', () {
      expect(BudgetCategory.dining.apiValue, 'dine_in');
      expect(BudgetCategory.groceries.apiValue, 'grocery');
    });

    test('fromApiValue throws on an unknown value', () {
      expect(() => BudgetCategoryX.fromApiValue('delivery'),
          throwsArgumentError);
    });
  });

  group('BudgetTransaction.fromJson', () {
    test('maps a real spending-record API response', () {
      final json = {
        'id': 1,
        'store': 21,
        'amount': '42.50',
        'spending_type': 'grocery',
        'date_spent': '2026-07-20',
        'created_at': '2026-07-23T16:07:35.006936Z',
      };

      final tx = BudgetTransaction.fromJson(json);

      expect(tx.id, '1');
      expect(tx.storeId, '21');
      expect(tx.storeName, isNull);
      expect(tx.category, BudgetCategory.groceries);
      expect(tx.amount, 42.50);
      expect(tx.dateSpent, DateTime(2026, 7, 20));
      expect(tx.notes, isNull);
      expect(tx.createdAt, DateTime.parse('2026-07-23T16:07:35.006936Z'));
    });

    test('handles a null store', () {
      final json = {
        'id': 2,
        'store': null,
        'amount': '15.00',
        'spending_type': 'dine_in',
        'date_spent': '2026-07-21',
        'created_at': '2026-07-23T16:07:35.154849Z',
      };

      final tx = BudgetTransaction.fromJson(json);

      expect(tx.storeId, isNull);
      expect(tx.category, BudgetCategory.dining);
    });
  });

  group('BudgetTransaction.displayLabel', () {
    test('uses storeName when present', () {
      final tx = BudgetTransaction(
        id: '1',
        storeId: '21',
        storeName: 'Jaya Grocer',
        category: BudgetCategory.groceries,
        amount: 10,
        dateSpent: DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 20),
      );
      expect(tx.displayLabel, 'Jaya Grocer');
    });

    test('falls back to the category label when storeName is null', () {
      final tx = BudgetTransaction(
        id: '2',
        category: BudgetCategory.dining,
        amount: 10,
        dateSpent: DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 20),
      );
      expect(tx.displayLabel, 'Dining Out expense');
    });
  });

  group('BudgetTransactionDraft.toRequestJson', () {
    test('builds the request body sent to POST/PUT', () {
      final draft = BudgetTransactionDraft(
        storeId: '21',
        name: 'Jaya Grocer',
        category: BudgetCategory.groceries,
        amount: 42.50,
        dateSpent: DateTime(2026, 7, 20),
        notes: 'weekly shop',
      );

      final json = draft.toRequestJson();

      expect(json, {
        'store': 21,
        'amount': 42.50,
        'spending_type': 'grocery',
        'date_spent': '2026-07-20',
      });
    });

    test('sends a null store when none was picked', () {
      final draft = BudgetTransactionDraft(
        name: 'Street vendor',
        category: BudgetCategory.dining,
        amount: 5.5,
        dateSpent: DateTime(2026, 1, 5),
      );

      expect(draft.toRequestJson()['store'], isNull);
      expect(draft.toRequestJson()['date_spent'], '2026-01-05');
    });
  });
}
