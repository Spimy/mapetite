import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/recipe_model.dart';

class IngredientRow extends StatelessWidget {
  final RecipeIngredient ingredient;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const IngredientRow({
    super.key,
    required this.ingredient,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: AppColors.neutral400, width: 1.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ingredient.name,
                            style: AppTypography.body1.copyWith(
                              color: isChecked
                                  ? AppColors.neutral400
                                  : AppColors.neutral,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          ingredient.quantity,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (ingredient.notSourcedNearby)
                      _WarningBadge()
                    else if (ingredient.storeName != null)
                      _StoreBadge(ingredient: ingredient),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final RecipeIngredient ingredient;

  const _StoreBadge({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final cost = ingredient.estimatedCost;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, size: 11, color: AppColors.secondary),
          const SizedBox(width: 3),
          Text(
            cost != null
                ? '${ingredient.storeName}  RM ${cost.toStringAsFixed(2)} est.'
                : ingredient.storeName ?? '',
            style: AppTypography.caption.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _WarningBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            'Ingredient not sourced nearby',
            style: AppTypography.caption.copyWith(color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}
