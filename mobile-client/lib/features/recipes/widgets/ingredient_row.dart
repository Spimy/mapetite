import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/recipe_model.dart';

class IngredientRow extends StatelessWidget {
  final RecipeIngredient ingredient;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const IngredientRow({
    super.key,
    required this.ingredient,
    required this.isChecked,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: isChecked
              ? const Color(0xFFFFF8E1)  // amber-50 tint — "needs buying"
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onChanged(!isChecked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isChecked
                          ? const Color(0xFFF59E0B)  // amber
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isChecked
                            ? const Color(0xFFF59E0B)
                            : AppColors.neutral400,
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.shopping_cart,
                            size: 14,
                            color: AppColors.white,
                          )
                        : null,
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
                                    ? const Color(0xFF92400E)  // amber-800
                                    : AppColors.neutral,
                                fontWeight: isChecked
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
        ),
        if (!isLast)
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
        children: [
          const Icon(Icons.storefront_outlined, size: 11, color: AppColors.secondary),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              cost != null
                  ? '${ingredient.storeName}  RM ${cost.toStringAsFixed(2)} est.'
                  : ingredient.storeName ?? '',
              style: AppTypography.caption.copyWith(color: AppColors.secondary),
              overflow: TextOverflow.ellipsis,
            ),
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
        children: [
          const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Ingredient not sourced nearby',
              style: AppTypography.caption.copyWith(color: AppColors.warning),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
