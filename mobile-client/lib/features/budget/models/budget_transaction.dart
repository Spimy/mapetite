enum BudgetCategory { groceries, dining, delivery }

extension BudgetCategoryX on BudgetCategory {
  String get label {
    switch (this) {
      case BudgetCategory.groceries:
        return 'Groceries';
      case BudgetCategory.dining:
        return 'Dining Out';
      case BudgetCategory.delivery:
        return 'Delivery';
    }
  }
}

class BudgetTransaction {
  final String id;
  final BudgetCategory category;
  final String name;
  final double amount;
  final DateTime dateTime;
  final String? notes;

  const BudgetTransaction({
    required this.id,
    required this.category,
    required this.name,
    required this.amount,
    required this.dateTime,
    this.notes,
  });
}
