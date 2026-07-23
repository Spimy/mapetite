import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_state.dart';
import '../models/budget_summary.dart';
import '../models/budget_transaction.dart';
import '../services/budget_service.dart';
import '../../../shared/providers/store_providers.dart';
import '../../../shared/services/profile_service.dart';

class BudgetNotifier extends AsyncNotifier<BudgetState> {
  final BudgetService _budgetService = BudgetService();
  final ProfileService _profileService = ProfileService();

  @override
  Future<BudgetState> build() async {
    final results = await Future.wait([
      _budgetService.getTransactions(),
      _budgetService.getSummary(),
      _profileService.getProfile(),
    ]);
    final transactions = results[0] as List<BudgetTransaction>;
    final summary = results[1] as BudgetSummary;
    final profile = results[2] as Map<String, dynamic>;

    return BudgetState(
      transactions: await _resolveStoreNames(transactions),
      dineInBudget:
          double.tryParse(profile['dine_in_budget']?.toString() ?? '') ?? 0,
      groceryBudget:
          double.tryParse(profile['grocery_budget']?.toString() ?? '') ?? 0,
      spendingAlertPercent:
          (profile['spending_alert_percent'] as num?)?.toInt() ?? 80,
      summary: summary,
    );
  }

  Future<List<BudgetTransaction>> _resolveStoreNames(
    List<BudgetTransaction> transactions,
  ) async {
    final ids = transactions.map((t) => t.storeId).whereType<String>().toSet();
    if (ids.isEmpty) return transactions;

    final names = <String, String>{};
    for (final id in ids) {
      try {
        final store = await ref.read(storeDetailProvider(id).future);
        names[id] = store.businessName;
      } catch (_) {
        // Store lookup failed (deleted store, network hiccup) — displayLabel
        // falls back to the category label, which is fine.
      }
    }

    return transactions
        .map((t) => names.containsKey(t.storeId)
            ? t.copyWith(storeName: names[t.storeId])
            : t)
        .toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> addTransaction(
    BudgetTransactionDraft draft, {
    String? draftDisplayName,
  }) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current == null) return;

    final optimistic = BudgetTransaction(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      storeId: draft.storeId,
      storeName: draftDisplayName,
      category: draft.category,
      amount: draft.amount,
      dateSpent: draft.dateSpent,
      notes: draft.notes,
      createdAt: DateTime.now(),
    );
    state = AsyncData(
      current.copyWith(transactions: [optimistic, ...current.transactions]),
    );

    try {
      await _budgetService.addTransaction(draft);
      await refresh();
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        transactions: current.transactions.where((t) => t.id != id).toList(),
      ),
    );

    try {
      await _budgetService.deleteTransaction(id);
      await refresh();
    } catch (e) {
      state = previous;
      rethrow;
    }
  }

  /// Re-creates a deleted transaction (delete is permanent server-side, so
  /// "undo" is really "add it back" — it will get a new id).
  Future<void> restoreTransaction(BudgetTransaction tx) async {
    await addTransaction(
      BudgetTransactionDraft(
        storeId: tx.storeId,
        name: tx.displayLabel,
        category: tx.category,
        amount: tx.amount,
        dateSpent: tx.dateSpent,
        notes: tx.notes,
      ),
      draftDisplayName: tx.storeName,
    );
  }

  Future<void> adjustBudget({
    double? dineIn,
    double? grocery,
    int? alertPercent,
  }) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      dineInBudget: dineIn,
      groceryBudget: grocery,
      spendingAlertPercent: alertPercent,
    ));

    try {
      await _profileService.updateProfile({
        if (dineIn != null) 'dine_in_budget': dineIn,
        if (grocery != null) 'grocery_budget': grocery,
        if (alertPercent != null) 'spending_alert_percent': alertPercent,
      });
    } catch (e) {
      state = previous;
      rethrow;
    }
  }
}

final budgetProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);
