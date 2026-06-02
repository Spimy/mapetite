import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/grocery_list_model.dart';

class GroceryItemTile extends StatelessWidget {
  final GroceryListItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.errorLight,
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _Checkbox(isChecked: item.isChecked, onTap: onToggle),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.body1.copyWith(
                        color: item.isChecked
                            ? AppColors.neutral400
                            : AppColors.neutral,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          item.quantity,
                          style: AppTypography.caption.copyWith(
                            color: item.isChecked
                                ? AppColors.neutral400
                                : AppColors.neutral600,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.neutral400,
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: AppTypography.caption.copyWith(
                            color: item.isChecked
                                ? AppColors.neutral400
                                : AppColors.secondary,
                          ),
                        ),
                        Text(
                          item.storeName,
                          style: AppTypography.caption.copyWith(
                            color: item.isChecked
                                ? AppColors.neutral400
                                : AppColors.secondary,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'RM ${item.estimatedPrice.toStringAsFixed(2)}',
                style: AppTypography.body1.copyWith(
                  color: item.isChecked ? AppColors.neutral400 : AppColors.neutral,
                  fontWeight: FontWeight.w600,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const _Checkbox({required this.isChecked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.neutral400,
            width: 1.5,
          ),
        ),
        child: isChecked
            ? const Icon(Icons.check, size: 14, color: AppColors.white)
            : null,
      ),
    );
  }
}
