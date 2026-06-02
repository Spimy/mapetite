import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/recipe_model.dart';

class RecipeStepTile extends StatelessWidget {
  final RecipeStep step;
  final bool isLast;

  const RecipeStepTile({super.key, required this.step, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isFirst = step.stepNumber == 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.primary : AppColors.white,
                  shape: BoxShape.circle,
                  border: isFirst
                      ? null
                      : Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: AppTypography.label.copyWith(
                      color: isFirst ? AppColors.white : AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  step.description,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.neutral,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
