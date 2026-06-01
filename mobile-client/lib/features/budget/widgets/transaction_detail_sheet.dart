import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../models/budget_transaction.dart';
import '../providers/budget_provider.dart';

void showTransactionDetailSheet(
    BuildContext context, BudgetTransaction tx) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _TransactionDetailSheet(transaction: tx),
    ),
  );
}

class _TransactionDetailSheet extends ConsumerWidget {
  final BudgetTransaction transaction;

  const _TransactionDetailSheet({required this.transaction});

  IconData get _icon {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case BudgetCategory.dining:
        return Icons.restaurant_outlined;
    }
  }

  Color get _iconBg {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return AppColors.primaryLight;
      case BudgetCategory.dining:
        return AppColors.warningLight;
    }
  }

  Color get _iconColor {
    switch (transaction.category) {
      case BudgetCategory.groceries:
        return AppColors.primary;
      case BudgetCategory.dining:
        return AppColors.warning;
    }
  }

  String _fullDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} at $time';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(_icon, size: AppSpacing.iconLg, color: _iconColor),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Name
          Text(transaction.name,
              style: AppTypography.headline1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),

          // Category + date
          Text(
            '${transaction.category.label}  •  ${_fullDateTime(transaction.dateTime)}',
            style: AppTypography.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount
          Text(
            '-RM ${transaction.amount.toStringAsFixed(2)}',
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),

          // Notes
          if (transaction.notes != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Notes',
                  style: AppTypography.label
                      .copyWith(color: AppColors.neutral600)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(transaction.notes!, style: AppTypography.body1),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.md),

          // Delete
          TextButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline,
                size: AppSpacing.iconSm, color: AppColors.error),
            label: Text('Delete Expense',
                style: AppTypography.body1.copyWith(color: AppColors.error)),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${transaction.name}" from your records?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(budgetProvider.notifier).deleteTransaction(transaction.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text('Expense deleted',
                    style: AppTypography.body1.copyWith(color: AppColors.white)),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 14),
              ),
            ],
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    }
  }
}
