import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../models/budget_transaction.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_bar_chart.dart';
import '../widgets/adjust_budget_sheet.dart';

class SpendingAnalyticsScreen extends ConsumerStatefulWidget {
  final String? categoryFilter;

  const SpendingAnalyticsScreen({super.key, this.categoryFilter});

  @override
  ConsumerState<SpendingAnalyticsScreen> createState() =>
      _SpendingAnalyticsScreenState();
}

class _SpendingAnalyticsScreenState
    extends ConsumerState<SpendingAnalyticsScreen> {
  String _period = 'Month';

  static const List<String> _periods = ['Week', 'Month', 'Year'];

  static const List<String> _monthAbbrs = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<String> _barLabels() {
    final now = DateTime.now();
    switch (_period) {
      case 'Week':
        return List.generate(4, (i) {
          final weekStart =
              now.subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
          return '${_monthAbbrs[weekStart.month - 1]} ${weekStart.day}';
        });
      case 'Year':
        return List.generate(4, (i) => '${now.year - 3 + i}');
      default: // Month
        return List.generate(4, (i) {
          var m = now.month - 3 + i;
          while (m <= 0) { m += 12; }
          return _monthAbbrs[m - 1];
        });
    }
  }

  List<double> _barAmounts(List<BudgetTransaction> transactions) {
    final now = DateTime.now();
    switch (_period) {
      case 'Week':
        return List.generate(4, (i) {
          final weekMon = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
          final weekSun = weekMon.add(const Duration(days: 6));
          return transactions
              .where((t) =>
                  !t.dateTime.isBefore(weekMon) &&
                  !t.dateTime.isAfter(
                      DateTime(weekSun.year, weekSun.month, weekSun.day, 23, 59, 59)))
              .fold(0.0, (s, t) => s + t.amount);
        });
      case 'Year':
        return List.generate(4, (i) {
          final y = now.year - 3 + i;
          return transactions
              .where((t) => t.dateTime.year == y)
              .fold(0.0, (s, t) => s + t.amount);
        });
      default: // Month
        return List.generate(4, (i) {
          var m = now.month - 3 + i;
          var y = now.year;
          while (m <= 0) { m += 12; y--; }
          return transactions
              .where((t) => t.dateTime.year == y && t.dateTime.month == m)
              .fold(0.0, (s, t) => s + t.amount);
        });
    }
  }

  List<double> _categoryBarAmounts(
      List<BudgetTransaction> transactions, BudgetCategory category) {
    final now = DateTime.now();
    switch (_period) {
      case 'Week':
        return List.generate(4, (i) {
          final weekMon = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
          final weekSun = weekMon.add(const Duration(days: 6));
          return transactions
              .where((t) =>
                  t.category == category &&
                  !t.dateTime.isBefore(weekMon) &&
                  !t.dateTime.isAfter(DateTime(
                      weekSun.year, weekSun.month, weekSun.day, 23, 59, 59)))
              .fold(0.0, (s, t) => s + t.amount);
        });
      case 'Year':
        return List.generate(4, (i) {
          final y = now.year - 3 + i;
          return transactions
              .where((t) => t.category == category && t.dateTime.year == y)
              .fold(0.0, (s, t) => s + t.amount);
        });
      default: // Month
        return List.generate(4, (i) {
          var m = now.month - 3 + i;
          var y = now.year;
          while (m <= 0) {
            m += 12;
            y--;
          }
          return transactions
              .where((t) =>
                  t.category == category &&
                  t.dateTime.year == y &&
                  t.dateTime.month == m)
              .fold(0.0, (s, t) => s + t.amount);
        });
    }
  }

  String _cardTitle() {
    switch (_period) {
      case 'Week': return 'Weekly Spending';
      case 'Year': return 'Yearly Spending';
      default: return 'Monthly Spending';
    }
  }

  String _cardSubtitle() {
    switch (_period) {
      case 'Week': return 'Comparison to previous 3 weeks';
      case 'Year': return 'Comparison to previous 3 years';
      default: return 'Comparison to previous 3 months';
    }
  }

  String _trendText(List<double> amounts) {
    if (amounts.length < 2) return '';
    final prev = amounts[amounts.length - 2];
    final curr = amounts.last;
    if (prev <= 0) return '';
    final pct = ((curr - prev) / prev * 100).abs().toStringAsFixed(0);
    return curr < prev ? '↓ $pct% vs last mo' : '↑ $pct% vs last mo';
  }

  bool _isDown(List<double> amounts) {
    if (amounts.length < 2 || amounts[amounts.length - 2] <= 0) return true;
    return amounts.last < amounts[amounts.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final transactions = budget.transactions;
    final totalAmounts = _barAmounts(transactions);
    final groceriesAmounts =
        _categoryBarAmounts(transactions, BudgetCategory.groceries);
    final diningAmounts =
        _categoryBarAmounts(transactions, BudgetCategory.dining);
    final currentSpent = totalAmounts.last;
    final trendText = _trendText(totalAmounts);
    final trendDown = _isDown(totalAmounts);

    // Category filter: if set, we highlight it in key discoveries
    final cat = widget.categoryFilter;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTypography.headline2.copyWith(color: AppColors.primary),
        title: const Text('Insights'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
          ).copyWith(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Track your spending habits over time.',
                style: AppTypography.body2,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Period segmented control
              _buildPeriodToggle(),
              const SizedBox(height: AppSpacing.xxl),

              // Spending card (period-aware, dual-category bars)
              _buildSpendingCard(
                context,
                currentSpent,
                budget.monthlyBudget,
                trendText,
                trendDown,
                groceriesAmounts,
                diningAmounts,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Key discoveries
              Text('Key Discoveries', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.md),
              _buildInsightCard(
                icon: Icons.restaurant_outlined,
                iconBg: cat == 'dining'
                    ? AppColors.warningLight
                    : AppColors.primaryLight,
                iconColor: cat == 'dining'
                    ? AppColors.warning
                    : AppColors.primary,
                title: 'Dining out decreased',
                body: 'You spent ',
                boldPart: '15% less',
                bodySuffix:
                    ' on Dining Out this month compared to last. Great job cooking at home!',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInsightCard(
                icon: Icons.local_grocery_store_outlined,
                iconBg: cat == 'groceries'
                    ? AppColors.primaryLight
                    : AppColors.tertiaryDark,
                iconColor: AppColors.primary,
                title: 'Weekend Spikes',
                body: 'Your Grocery spending peaks on ',
                boldPart: 'Saturdays',
                bodySuffix:
                    '. Consider planning meals earlier to spread out costs.',
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Dark CTA card
              _buildCtaCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _periods.map((p) {
          final selected = p == _period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  p,
                  textAlign: TextAlign.center,
                  style: AppTypography.body1.copyWith(
                    color: selected ? AppColors.white : AppColors.neutral600,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpendingCard(
    BuildContext context,
    double spent,
    double goal,
    String trendText,
    bool trendDown,
    List<double> groceriesAmounts,
    List<double> diningAmounts,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_cardTitle(), style: AppTypography.headline3),
                    Text(_cardSubtitle(),
                        style: AppTypography.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${spent.toStringAsFixed(0)}',
                    style: AppTypography.display
                        .copyWith(color: AppColors.primary, fontSize: 22),
                  ),
                  if (trendText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: trendDown
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        trendText,
                        style: AppTypography.label.copyWith(
                            color: trendDown
                                ? AppColors.success
                                : AppColors.error),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BudgetBarChart(
            groceriesAmounts: groceriesAmounts,
            diningAmounts: diningAmounts,
            periodLabels: _barLabels(),
            goal: goal,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String body,
    required String boldPart,
    required String bodySuffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, size: AppSpacing.iconSm, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.body1
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    style: AppTypography.body2,
                    children: [
                      TextSpan(text: body),
                      TextSpan(
                        text: boldPart,
                        style: AppTypography.body2.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral),
                      ),
                      TextSpan(text: bodySuffix),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust your budget?',
                style: AppTypography.headline3
                    .copyWith(color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Based on your recent habits, we recommend adjusting your monthly food allowance.',
                style: AppTypography.body2
                    .copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () => showAdjustBudgetSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm),
                ),
                child: Text('Review Budget',
                    style: AppTypography.button
                        .copyWith(color: AppColors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
