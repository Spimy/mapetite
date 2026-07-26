import 'budget_summary.dart';
import 'budget_transaction.dart';

class BudgetState {
  final List<BudgetTransaction> transactions;
  final double dineInBudget;
  final double groceryBudget;
  final int spendingAlertPercent;
  final BudgetSummary? summary;

  const BudgetState({
    required this.transactions,
    this.dineInBudget = 0,
    this.groceryBudget = 0,
    this.spendingAlertPercent = 80,
    this.summary,
  });

  double get monthlyBudget => dineInBudget + groceryBudget;

  double get diningSpent => summary?.dineIn.spent ?? 0;
  double get groceriesSpent => summary?.grocery.spent ?? 0;
  double get totalSpent => diningSpent + groceriesSpent;

  List<BudgetTransaction> get recentTransactions {
    final sorted = List<BudgetTransaction>.from(transactions)
      ..sort((a, b) => b.dateSpent.compareTo(a.dateSpent));
    return sorted.take(3).toList();
  }

  List<BudgetTransaction> get allSortedDesc {
    final sorted = List<BudgetTransaction>.from(transactions)
      ..sort((a, b) => b.dateSpent.compareTo(a.dateSpent));
    return sorted;
  }

  BudgetState copyWith({
    List<BudgetTransaction>? transactions,
    double? dineInBudget,
    double? groceryBudget,
    int? spendingAlertPercent,
    BudgetSummary? summary,
  }) =>
      BudgetState(
        transactions: transactions ?? this.transactions,
        dineInBudget: dineInBudget ?? this.dineInBudget,
        groceryBudget: groceryBudget ?? this.groceryBudget,
        spendingAlertPercent: spendingAlertPercent ?? this.spendingAlertPercent,
        summary: summary ?? this.summary,
      );
}
