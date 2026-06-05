import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../models/budget_transaction.dart';

class TransactionTile extends StatelessWidget {
  final BudgetTransaction transaction;
  final VoidCallback? onTap;
  final bool showDivider;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDivider = true,
  });

  IconData get _icon {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case BudgetCategory.dining:
        return Icons.restaurant_outlined;
      case BudgetCategory.delivery:
        return Icons.delivery_dining_outlined;
    }
  }

  Color get _iconBg {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return AppColors.primaryLight;
      case BudgetCategory.dining:
        return AppColors.warningLight;
      case BudgetCategory.delivery:
        return AppColors.secondaryLight;
    }
  }

  Color get _iconColor {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return AppColors.primary;
      case BudgetCategory.dining:
        return AppColors.warning;
      case BudgetCategory.delivery:
        return AppColors.secondary;
    }
  }

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(txDay).inDays;
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Today, $timeStr';
    if (diff == 1) return 'Yesterday, $timeStr';
    return '${_monthAbbr(dt.month)} ${dt.day}, $timeStr';
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child:
                      Icon(_icon, size: AppSpacing.iconSm, color: _iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name,
                        style: AppTypography.body1
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.category.label} • ${_relativeTime(transaction.dateTime)}',
                        style: AppTypography.body2,
                      ),
                    ],
                  ),
                ),
                Text(
                  '-RM ${transaction.amount.toStringAsFixed(2)}',
                  style: AppTypography.body1
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1, color: AppColors.border,
              indent: AppSpacing.lg, endIndent: AppSpacing.lg),
      ],
    );
  }
}
