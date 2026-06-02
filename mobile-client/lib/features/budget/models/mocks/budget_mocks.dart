import '../budget_transaction.dart';

abstract class BudgetMocks {
  static List<BudgetTransaction> get transactions {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;
    final d = now.day;
    return [
      BudgetTransaction(
        id: 'bm1',
        category: BudgetCategory.groceries,
        name: 'Jaya Grocer',
        amount: 45.20,
        dateTime: DateTime(y, m, d, 10, 42),
        notes: 'Weekly top-up',
      ),
      BudgetTransaction(
        id: 'bm2',
        category: BudgetCategory.dining,
        name: 'Salad Atelier',
        amount: 22.50,
        dateTime: DateTime(y, m, _clamp(d - 1, 1), 13, 15),
      ),
      BudgetTransaction(
        id: 'bm3',
        category: BudgetCategory.groceries,
        name: 'Village Grocer',
        amount: 78.00,
        dateTime: DateTime(y, m, _clamp(d - 2, 1), 14, 30),
      ),
      BudgetTransaction(
        id: 'bm4',
        category: BudgetCategory.dining,
        name: 'Nasi Kandar Pelita',
        amount: 12.50,
        dateTime: DateTime(y, m, _clamp(d - 3, 1), 19, 45),
      ),
      BudgetTransaction(
        id: 'bm5',
        category: BudgetCategory.dining,
        name: 'Starbucks',
        amount: 16.00,
        dateTime: DateTime(y, m, _clamp(d - 4, 1), 8, 30),
      ),
      BudgetTransaction(
        id: 'bm6',
        category: BudgetCategory.groceries,
        name: 'AEON Supermarket',
        amount: 156.30,
        dateTime: DateTime(y, m, _clamp(d - 7, 1), 11, 0),
      ),
      BudgetTransaction(
        id: 'bm7',
        category: BudgetCategory.dining,
        name: 'Mamak Corner',
        amount: 8.50,
        dateTime: DateTime(y, m, _clamp(d - 10, 1), 20, 0),
      ),
      BudgetTransaction(
        id: 'bm8',
        category: BudgetCategory.groceries,
        name: 'Cold Storage',
        amount: 63.40,
        dateTime: DateTime(y, m, _clamp(d - 12, 1), 17, 20),
      ),
    ];
  }

  static int _clamp(int day, int min) => day < min ? min : day;
}
