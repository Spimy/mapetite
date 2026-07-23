import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapetite/core/network/api_client.dart';
import 'package:mapetite/core/network/api_endpoints.dart';
import 'package:mapetite/features/auth/models/auth_tokens.dart';
import 'package:mapetite/features/auth/services/auth_token_service.dart';
import 'package:mapetite/features/budget/models/budget_transaction.dart';
import 'package:mapetite/features/budget/services/budget_service.dart';
import 'package:mapetite/shared/services/storage_service.dart';

const _testUsername = 'integration_test';
const _testPassword = 'IntegrationTest123!';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    final response = await ApiClient.post(
      ApiEndpoints.login,
      data: {'username': _testUsername, 'password': _testPassword},
    );
    await AuthTokenService.saveTokens(
      AuthTokens.fromJson(response.data as Map<String, dynamic>),
    );
  });

  group('BudgetService (integration — requires local backend running and seeded)', () {
    final service = BudgetService();
    String? createdId;

    tearDownAll(() async {
      if (createdId != null) {
        await service.deleteTransaction(createdId!);
      }
    });

    test('addTransaction creates a record and returns it parsed', () async {
      final draft = BudgetTransactionDraft(
        name: 'Integration test expense',
        category: BudgetCategory.dining,
        amount: 12.34,
        dateSpent: DateTime(2026, 7, 20),
      );

      final created = await service.addTransaction(draft);
      createdId = created.id;

      expect(created.amount, 12.34);
      expect(created.category, BudgetCategory.dining);
      expect(created.storeId, isNull);
    });

    test('getTransactions includes the created record', () async {
      final transactions = await service.getTransactions();
      expect(transactions.any((t) => t.id == createdId), isTrue);
    });

    test('updateTransaction changes the amount', () async {
      final updated = await service.updateTransaction(
        createdId!,
        BudgetTransactionDraft(
          name: 'Integration test expense (edited)',
          category: BudgetCategory.dining,
          amount: 20.00,
          dateSpent: DateTime(2026, 7, 20),
        ),
      );
      expect(updated.amount, 20.00);
    });

    test('getSummary returns dine_in/grocery totals for the given month', () async {
      final summary = await service.getSummary(month: 7, year: 2026);
      expect(summary.month, 7);
      expect(summary.year, 2026);
      expect(summary.dineIn.spent, greaterThanOrEqualTo(20.00));
    });

    test('deleteTransaction removes it', () async {
      await service.deleteTransaction(createdId!);
      final transactions = await service.getTransactions();
      expect(transactions.any((t) => t.id == createdId), isFalse);
      createdId = null; // already deleted — skip tearDownAll's cleanup
    });
  });
}
