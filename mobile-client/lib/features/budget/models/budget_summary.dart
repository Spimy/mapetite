/// Mirrors `BudgetCategorySummarySerializer`.
class BudgetCategorySummary {
  final double spent;
  final double budget;
  final double percentageUsed;

  const BudgetCategorySummary({
    required this.spent,
    required this.budget,
    required this.percentageUsed,
  });

  factory BudgetCategorySummary.fromJson(Map<String, dynamic> json) {
    return BudgetCategorySummary(
      spent: double.parse(json['spent'].toString()),
      budget: double.parse(json['budget'].toString()),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
    );
  }
}

/// Mirrors `SpendingSummaryResponseSerializer` — the response shape of
/// `GET spending-records/summary/`.
class BudgetSummary {
  final int month;
  final int year;
  final BudgetCategorySummary dineIn;
  final BudgetCategorySummary grocery;

  const BudgetSummary({
    required this.month,
    required this.year,
    required this.dineIn,
    required this.grocery,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      month: json['month'] as int,
      year: json['year'] as int,
      dineIn: BudgetCategorySummary.fromJson(
          json['dine_in'] as Map<String, dynamic>),
      grocery: BudgetCategorySummary.fromJson(
          json['grocery'] as Map<String, dynamic>),
    );
  }
}
