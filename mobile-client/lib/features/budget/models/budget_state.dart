import 'budget_transaction.dart';

class BudgetState {
  final List<BudgetTransaction> transactions;
  final double monthlyBudget;
  final double groceriesBudget;
  final double diningBudget;

  const BudgetState({
    required this.transactions,
    this.monthlyBudget = 1000.0,
    this.groceriesBudget = 400.0,
    this.diningBudget = 400.0,
  });

  List<BudgetTransaction> get _currentMonth {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.dateTime.year == now.year && t.dateTime.month == now.month)
        .toList();
  }

  double get totalSpent =>
      _currentMonth.fold(0.0, (s, t) => s + t.amount);

  double get groceriesSpent => _currentMonth
      .where((t) => t.category == BudgetCategory.groceries)
      .fold(0.0, (s, t) => s + t.amount);

  double get diningSpent => _currentMonth
      .where((t) => t.category == BudgetCategory.dining)
      .fold(0.0, (s, t) => s + t.amount);

  List<BudgetTransaction> get recentTransactions {
    final sorted = List<BudgetTransaction>.from(_currentMonth)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted.take(3).toList();
  }

  List<BudgetTransaction> get allSortedDesc {
    final sorted = List<BudgetTransaction>.from(transactions)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted;
  }

  BudgetState copyWith({
    List<BudgetTransaction>? transactions,
    double? monthlyBudget,
    double? groceriesBudget,
    double? diningBudget,
  }) =>
      BudgetState(
        transactions: transactions ?? this.transactions,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
        groceriesBudget: groceriesBudget ?? this.groceriesBudget,
        diningBudget: diningBudget ?? this.diningBudget,
      );
}
