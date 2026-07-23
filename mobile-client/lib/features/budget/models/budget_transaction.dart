enum BudgetCategory { dining, groceries }

extension BudgetCategoryX on BudgetCategory {
  String get label {
    switch (this) {
      case BudgetCategory.groceries:
        return 'Groceries';
      case BudgetCategory.dining:
        return 'Dining Out';
    }
  }

  String get apiValue {
    switch (this) {
      case BudgetCategory.dining:
        return 'dine_in';
      case BudgetCategory.groceries:
        return 'grocery';
    }
  }

  static BudgetCategory fromApiValue(String value) => switch (value) {
        'dine_in' => BudgetCategory.dining,
        'grocery' => BudgetCategory.groceries,
        _ => throw ArgumentError('Unknown spending_type: $value'),
      };
}

/// Mirrors `SpendingRecordSerializer`. The backend has no free-text label
/// field, so [displayLabel] falls back to the category when [storeName]
/// (resolved client-side from the store id) is unavailable.
class BudgetTransaction {
  final String id;
  final String? storeId;
  final String? storeName;
  final BudgetCategory category;
  final double amount;
  final DateTime dateSpent;
  final String? notes;
  final DateTime createdAt;

  const BudgetTransaction({
    required this.id,
    this.storeId,
    this.storeName,
    required this.category,
    required this.amount,
    required this.dateSpent,
    this.notes,
    required this.createdAt,
  });

  String get displayLabel => storeName ?? '${category.label} expense';

  factory BudgetTransaction.fromJson(Map<String, dynamic> json) {
    return BudgetTransaction(
      id: json['id'].toString(),
      storeId: json['store']?.toString(),
      category: BudgetCategoryX.fromApiValue(json['spending_type'] as String),
      amount: double.parse(json['amount'].toString()),
      dateSpent: DateTime.parse(json['date_spent'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  BudgetTransaction copyWith({String? storeName}) => BudgetTransaction(
        id: id,
        storeId: storeId,
        storeName: storeName ?? this.storeName,
        category: category,
        amount: amount,
        dateSpent: dateSpent,
        notes: notes,
        createdAt: createdAt,
      );
}

/// What the Add/Edit Transaction sheet builds from form input. `name`/`notes`
/// are UI-only — the backend has nowhere to persist them (see #94) — so
/// [toRequestJson] omits them.
class BudgetTransactionDraft {
  final String? storeId;
  final String name;
  final BudgetCategory category;
  final double amount;
  final DateTime dateSpent;
  final String? notes;

  const BudgetTransactionDraft({
    this.storeId,
    required this.name,
    required this.category,
    required this.amount,
    required this.dateSpent,
    this.notes,
  });

  Map<String, dynamic> toRequestJson() => {
        'store': storeId != null ? int.parse(storeId!) : null,
        'amount': amount,
        'spending_type': category.apiValue,
        'date_spent':
            '${dateSpent.year.toString().padLeft(4, '0')}-${dateSpent.month.toString().padLeft(2, '0')}-${dateSpent.day.toString().padLeft(2, '0')}',
      };
}
