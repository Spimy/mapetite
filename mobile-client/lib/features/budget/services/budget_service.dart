import '../models/budget_state.dart';
import '../models/budget_transaction.dart';
import '../models/mocks/budget_mocks.dart';

class BudgetService {
  Future<BudgetState> getBudgetOverview() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return BudgetState(transactions: BudgetMocks.transactions);
    // TODO: Replace with real API call to GET /api/v1/budget/overview
  }

  Future<List<BudgetTransaction>> getTransactions({
    String? month,
    int page = 1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return BudgetMocks.transactions;
    // TODO: Replace with real API call to GET /api/v1/budget/transactions?month=:month&page=:page
  }

  Future<BudgetTransaction> addTransaction(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BudgetMocks.transactions.first;
    // TODO: Replace with real API call to POST /api/v1/budget/transactions
  }

  Future<void> updateBudgetLimit(double newLimit) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: Replace with real API call to PATCH /api/v1/budget/limit
  }
}
