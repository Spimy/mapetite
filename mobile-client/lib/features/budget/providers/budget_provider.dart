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

  int? _year;
  int? _month;

  @override
  Future<BudgetState> build() => _load();

  Future<BudgetState> _load() async {
    final results = await Future.wait([
      _budgetService.getTransactions(month: _month, year: _year),
      _budgetService.getSummary(month: _month, year: _year),
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

  /// Re-fetches transactions and the summary for the given month/year so the
  /// month selector actually changes what's displayed, not just its label.
  Future<void> selectMonth(int year, int month) async {
    final previous = state;
    _year = year;
    _month = month;
    state = const AsyncLoading<BudgetState>().copyWithPrevious(previous);
    try {
      state = AsyncData(await _load());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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

  /// Re-runs [_load] on this same instance (rather than
  /// `ref.invalidateSelf()`, which would recreate the notifier and reset
  /// [_year]/[_month] back to the current month) so refreshing after a
  /// mutation preserves whatever month is currently selected.
  Future<void> refresh() async {
    state = AsyncData(await _load());
  }

  Future<void> addTransaction(
    BudgetTransactionDraft draft, {
    String? draftDisplayName,
  }) async {
    final current = await future;
    final previous = state;

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
    final current = await future;
    final previous = state;

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

  /// Updates a transaction in place via PUT, keeping its id. Deliberately
  /// not delete+add: if delete succeeds but the follow-up call fails, the
  /// original transaction would be permanently lost.
  Future<void> editTransaction(
    String id,
    BudgetTransactionDraft draft, {
    String? draftDisplayName,
  }) async {
    final current = await future;
    final previous = state;

    final updated = current.transactions.map((t) {
      if (t.id != id) return t;
      return BudgetTransaction(
        id: t.id,
        storeId: draft.storeId,
        storeName: draftDisplayName,
        category: draft.category,
        amount: draft.amount,
        dateSpent: draft.dateSpent,
        notes: draft.notes,
        createdAt: t.createdAt,
      );
    }).toList();
    state = AsyncData(current.copyWith(transactions: updated));

    try {
      await _budgetService.updateTransaction(id, draft);
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
    final current = await future;
    final previous = state;

    state = AsyncData(current.copyWith(
      dineInBudget: dineIn,
      groceryBudget: grocery,
      spendingAlertPercent: alertPercent,
    ));

    try {
      await _profileService.updateProfile({
        'dine_in_budget': ?dineIn,
        'grocery_budget': ?grocery,
        'spending_alert_percent': ?alertPercent,
      });
    } catch (e) {
      state = previous;
      rethrow;
    }
  }
}

final budgetProvider =
    AsyncNotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);
