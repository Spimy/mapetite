import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/profile_drawer.dart';
import '../../../routes/app_router.dart';
import '../providers/budget_provider.dart';
import '../models/budget_transaction.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../widgets/add_transaction_sheet.dart';

class BudgetOverviewScreen extends ConsumerStatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  ConsumerState<BudgetOverviewScreen> createState() =>
      _BudgetOverviewScreenState();
}

class _BudgetOverviewScreenState extends ConsumerState<BudgetOverviewScreen> {
  int _selectedMonthOffset = 0; // 0 = current month

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _monthLabel {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month - _selectedMonthOffset);
    return '${_monthNames[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ProfileDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTransactionSheet(context),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.lg),
                  _buildRingCard(budget),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCategoriesCard(budget),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentTransactionsCard(context, budget),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      title: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Icon(Icons.menu,
                  size: AppSpacing.iconMd, color: AppColors.neutral),
            ),
          ),
          const Spacer(),
          Text('Budget',
              style:
                  AppTypography.headline1.copyWith(color: AppColors.primary)),
          const Spacer(),
          _MonthSelector(
            label: _monthLabel,
            onPrev: () =>
                setState(() => _selectedMonthOffset++),
            onNext: _selectedMonthOffset > 0
                ? () => setState(() => _selectedMonthOffset--)
                : null,
          ),
        ],
      ),
    );
  }

  // ─── Budget Ring Card ─────────────────────────────────────────────────────

  Widget _buildRingCard(dynamic budget) {
    final spent = budget.totalSpent as double;
    final total = budget.monthlyBudget as double;
    final ratio = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final isExceeded = spent > total;
    final isWarning = !isExceeded && ratio >= 0.8;
    final pct = (ratio * 100).toStringAsFixed(0);

    Color arcColor;
    if (isExceeded) {
      arcColor = AppColors.error;
    } else if (isWarning) {
      arcColor = AppColors.warning;
    } else {
      arcColor = AppColors.secondary;
    }

    return _Card(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Monthly Spend', style: AppTypography.headline2),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _RingPainter(
                ratio: isExceeded ? 1.0 : ratio,
                arcColor: arcColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pct%',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('Spent',
                        style: AppTypography.body2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          RichText(
            text: TextSpan(
              style: AppTypography.headline1,
              children: [
                TextSpan(text: 'RM ${spent.toStringAsFixed(0)}'),
                TextSpan(
                  text: ' of RM ${total.toStringAsFixed(0)}',
                  style: AppTypography.headline1.copyWith(
                      color: AppColors.neutral600),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatusBanner(isExceeded, isWarning, ratio, spent, total),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
      bool isExceeded, bool isWarning, double ratio, double spent, double total) {
    if (isExceeded) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 16, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Budget exceeded.',
              style: AppTypography.body2.copyWith(
                  color: const Color(0xFFB91C1C)),
            ),
          ],
        ),
      );
    }
    if (isWarning) {
      final usedPct = (ratio * 100).toStringAsFixed(0);
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_outlined,
                size: 16, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'You have used $usedPct% of your budget.',
                style: AppTypography.body2.copyWith(
                    color: const Color(0xFF92400E)),
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.trending_down,
            size: 14, color: AppColors.success),
        const SizedBox(width: 4),
        Text(
          'On track to save this month',
          style: AppTypography.caption
              .copyWith(color: AppColors.success),
        ),
      ],
    );
  }

  // ─── Categories Card ──────────────────────────────────────────────────────

  Widget _buildCategoriesCard(dynamic budget) {
    final transactions =
        budget.transactions as List<BudgetTransaction>;
    final now = DateTime.now();
    final monthTx = transactions
        .where((t) =>
            t.dateTime.year == now.year && t.dateTime.month == now.month)
        .toList();

    double spentFor(BudgetCategory cat) =>
        monthTx.where((t) => t.category == cat).fold(0.0, (s, t) => s + t.amount);

    final diningSpent = spentFor(BudgetCategory.dining);
    final groceriesSpent = spentFor(BudgetCategory.groceries);
    final deliverySpent = spentFor(BudgetCategory.delivery);
    const diningBudget = 200.0;
    const groceriesBudget = 300.0;
    const deliveryBudget = 100.0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.md),
          _CategoryRow(
            icon: Icons.restaurant_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primary,
            label: 'Dining',
            spent: diningSpent,
            budget: diningBudget,
            progressColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _CategoryRow(
            icon: Icons.local_grocery_store_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.secondary,
            label: 'Groceries',
            spent: groceriesSpent,
            budget: groceriesBudget,
            progressColor: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          _CategoryRow(
            icon: Icons.delivery_dining_outlined,
            iconBg: AppColors.warningLight,
            iconColor: const Color(0xFF92400E),
            label: 'Delivery',
            spent: deliverySpent,
            budget: deliveryBudget,
            progressColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  // ─── Recent Transactions Card ─────────────────────────────────────────────

  Widget _buildRecentTransactionsCard(BuildContext context, dynamic budget) {
    final recent =
        budget.recentTransactions as List<BudgetTransaction>;

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
                AppSpacing.sm,
                AppSpacing.sm),
            child: Row(
              children: [
                Text('Recent', style: AppTypography.headline2),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.budgetTransactions),
                  child: Text('See All',
                      style: AppTypography.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text('No transactions this month',
                    style: AppTypography.body2),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < recent.length; i++)
                  _TransactionRow(
                    tx: recent[i],
                    showDivider: i < recent.length - 1,
                    onTap: () => showTransactionDetailSheet(context, recent[i]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color arcColor;

  const _RingPainter({required this.ratio, required this.arcColor});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.neutral100
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (ratio <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      ratio * 2 * math.pi,
      false,
      Paint()
        ..color = arcColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.arcColor != arcColor;
}

// ─── Month Selector ───────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const _MonthSelector({
    required this.label,
    required this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPrev,
          child: const Icon(Icons.chevron_left,
              size: AppSpacing.iconMd, color: AppColors.neutral600),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.label.copyWith(color: AppColors.neutral)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onNext,
          child: Icon(Icons.chevron_right,
              size: AppSpacing.iconMd,
              color: onNext != null
                  ? AppColors.neutral600
                  : AppColors.neutral200),
        ),
      ],
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final double spent;
  final double budget;
  final Color progressColor;

  const _CategoryRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.spent,
    required this.budget,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppTypography.body1
                      .copyWith(fontWeight: FontWeight.w500)),
            ),
            Text('RM ${spent.toStringAsFixed(0)}',
                style: AppTypography.headline3),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

// ─── Transaction Row ──────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  final BudgetTransaction tx;
  final bool showDivider;
  final VoidCallback onTap;

  const _TransactionRow({
    required this.tx,
    required this.showDivider,
    required this.onTap,
  });

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  String get _dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(tx.dateTime.year, tx.dateTime.month, tx.dateTime.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${tx.dateTime.day} ${_months[tx.dateTime.month - 1]}';
  }

  IconData get _categoryIcon {
    switch (tx.category) {
      case BudgetCategory.dining:
        return Icons.restaurant_outlined;
      case BudgetCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case BudgetCategory.delivery:
        return Icons.delivery_dining_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1)))
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_categoryIcon,
                  size: AppSpacing.iconSm, color: AppColors.neutral600),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tx.name,
                      style: AppTypography.body1
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('$_dateLabel · ${tx.category.label}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral600)),
                ],
              ),
            ),
            Text('-RM ${tx.amount.toStringAsFixed(2)}',
                style: AppTypography.headline3),
          ],
        ),
      ),
    );
  }
}

// ─── Card Container ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
