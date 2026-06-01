import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../routes/app_router.dart';
import '../providers/budget_provider.dart';
import '../models/budget_transaction.dart';
import '../widgets/budget_ring_chart.dart';
import '../widgets/category_progress_row.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/adjust_budget_sheet.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/transaction_detail_sheet.dart';

class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  _buildOverviewCard(context, ref, budget),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildBreakdownSection(context, budget),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildRecentTransactionsSection(context, budget),
                  const SizedBox(height: AppSpacing.xxl),
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
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      scrolledUnderElevation: 2,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      title: Stack(
        alignment: Alignment.center,
        children: [
          // Left: profile avatar (opens drawer)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: AppSpacing.avatarSm,
                height: AppSpacing.avatarSm,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.person,
                    size: 18, color: AppColors.primary),
              ),
            ),
          ),
          // Centre: title
          Text('Budget',
              style: AppTypography.headline2.copyWith(color: AppColors.neutral)),
          // Right: bell
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.neutral),
              onPressed: () => context.push(AppRoutes.notifications),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Monthly Overview Card ────────────────────────────────────────────────

  Widget _buildOverviewCard(
      BuildContext context, WidgetRef ref, dynamic budget) {
    return _Card(
      child: Column(
        children: [
          Text('Monthly Overview', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.xxl),
          BudgetRingChart(
            spent: budget.totalSpent,
            total: budget.monthlyBudget,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Adjust Budget',
                  onPressed: () => showAdjustBudgetSheet(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Add Expense',
                  variant: AppButtonVariant.outlined,
                  onPressed: () => showAddExpenseSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Breakdown ────────────────────────────────────────────────────────────

  Widget _buildBreakdownSection(BuildContext context, dynamic budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Breakdown', style: AppTypography.headline2),
            TextButton(
              onPressed: () => context.push(AppRoutes.budgetAnalytics),
              child: Text('View All',
                  style: AppTypography.body1
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              CategoryProgressRow(
                icon: Icons.local_grocery_store_outlined,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                label: 'Groceries',
                spent: budget.groceriesSpent,
                budget: budget.groceriesBudget,
                progressColor: AppColors.primary,
                onTap: () => context.push(
                    '${AppRoutes.budgetAnalytics}?category=groceries'),
              ),
              CategoryProgressRow(
                icon: Icons.restaurant_outlined,
                iconBg: AppColors.warningLight,
                iconColor: AppColors.warning,
                label: 'Dining Out',
                spent: budget.diningSpent,
                budget: budget.diningBudget,
                progressColor: AppColors.warning,
                showDivider: false,
                onTap: () => context.push(
                    '${AppRoutes.budgetAnalytics}?category=dining'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Recent Transactions ─────────────────────────────────────────────────

  Widget _buildRecentTransactionsSection(
      BuildContext context, dynamic budget) {
    final recent = budget.recentTransactions as List<BudgetTransaction>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions', style: AppTypography.headline2),
            TextButton(
              onPressed: () => context.push(AppRoutes.budgetTransactions),
              child: Text('View All',
                  style: AppTypography.body1.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          _Card(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text('No transactions this month',
                    style: AppTypography.body2),
              ),
            ),
          )
        else
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < recent.length; i++)
                  TransactionTile(
                    transaction: recent[i],
                    showDivider: i < recent.length - 1,
                    onTap: () => showTransactionDetailSheet(
                        context, recent[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Reusable card container ─────────────────────────────────────────────────

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
