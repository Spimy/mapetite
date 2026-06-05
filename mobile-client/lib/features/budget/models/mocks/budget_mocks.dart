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
        category: BudgetCategory.dining,
        name: 'Nasi Kandar Ali',
        amount: 24.50,
        dateTime: DateTime(y, m, d, 12, 30),
      ),
      BudgetTransaction(
        id: 'bm2',
        category: BudgetCategory.groceries,
        name: 'Jaya Grocer',
        amount: 112.90,
        dateTime: DateTime(y, m, _clamp(d - 1, 1), 14, 0),
      ),
      BudgetTransaction(
        id: 'bm3',
        category: BudgetCategory.delivery,
        name: 'GrabFood',
        amount: 45.00,
        dateTime: DateTime(y, m, _clamp(d - 2, 1), 19, 15),
      ),
      BudgetTransaction(
        id: 'bm4',
        category: BudgetCategory.dining,
        name: 'Kopitiam Old Town',
        amount: 18.00,
        dateTime: DateTime(y, m, _clamp(d - 4, 1), 8, 30),
      ),
      BudgetTransaction(
        id: 'bm5',
        category: BudgetCategory.groceries,
        name: '99 Speedmart',
        amount: 34.00,
        dateTime: DateTime(y, m, _clamp(d - 6, 1), 17, 45),
      ),
      BudgetTransaction(
        id: 'bm6',
        category: BudgetCategory.groceries,
        name: 'Village Grocer',
        amount: 78.00,
        dateTime: DateTime(y, m, _clamp(d - 8, 1), 14, 30),
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
        category: BudgetCategory.delivery,
        name: 'Foodpanda',
        amount: 32.00,
        dateTime: DateTime(y, m, _clamp(d - 12, 1), 12, 0),
      ),
    ];
  }

  static int _clamp(int day, int min) => day < min ? min : day;
}
