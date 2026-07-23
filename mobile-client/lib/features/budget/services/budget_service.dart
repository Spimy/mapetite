import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/budget_summary.dart';
import '../models/budget_transaction.dart';

class BudgetService {
  Future<List<BudgetTransaction>> getTransactions({int? month, int? year}) async {
    final response = await ApiClient.get(
      ApiEndpoints.budget,
      params: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(BudgetTransaction.fromJson).toList();
  }

  Future<BudgetTransaction> addTransaction(BudgetTransactionDraft draft) async {
    final response = await ApiClient.post(
      ApiEndpoints.budget,
      data: draft.toRequestJson(),
    );
    return BudgetTransaction.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BudgetTransaction> updateTransaction(
    String id,
    BudgetTransactionDraft draft,
  ) async {
    final response = await ApiClient.put(
      ApiEndpoints.budgetDetail(id),
      data: draft.toRequestJson(),
    );
    return BudgetTransaction.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await ApiClient.delete(ApiEndpoints.budgetDetail(id));
  }

  Future<BudgetSummary> getSummary({int? month, int? year}) async {
    final response = await ApiClient.get(
      ApiEndpoints.budgetSummary,
      params: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    return BudgetSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
