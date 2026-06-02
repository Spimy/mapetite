import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/recipe_model.dart';

class RecipeStepTile extends StatelessWidget {
  final RecipeStep step;

  const RecipeStepTile({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: step.stepNumber == 1 ? AppColors.primary : AppColors.white,
              shape: BoxShape.circle,
              border: step.stepNumber != 1
                  ? Border.all(color: AppColors.border, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: AppTypography.label.copyWith(
                  color: step.stepNumber == 1 ? AppColors.white : AppColors.neutral600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                step.description,
                style: AppTypography.body1.copyWith(
                  color: step.stepNumber == 1
                      ? AppColors.neutral
                      : AppColors.neutral600,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
