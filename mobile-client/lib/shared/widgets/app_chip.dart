import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum AppChipStyle { dietary, category, filter }

class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final AppChipStyle style;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.onTap,
    this.style = AppChipStyle.filter,
  });

  factory AppChip.halal({VoidCallback? onTap}) => AppChip(
        label: 'Halal',
        backgroundColor: AppColors.tagHalal,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        onTap: onTap,
      );

  factory AppChip.vegan({VoidCallback? onTap}) => AppChip(
        label: 'Vegan',
        backgroundColor: AppColors.tagVegan,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        onTap: onTap,
      );

  factory AppChip.vegetarian({VoidCallback? onTap}) => AppChip(
        label: 'Vegetarian',
        backgroundColor: AppColors.tagVegetarian,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        onTap: onTap,
      );

  factory AppChip.allergen(String allergen, {VoidCallback? onTap}) => AppChip(
        label: allergen,
        backgroundColor: AppColors.tagAllergen,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (isSelected ? AppColors.primaryLight : AppColors.neutral100);
    final fg = textColor ??
        (isSelected ? AppColors.primary : AppColors.neutral600);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(label, style: AppTypography.label.copyWith(color: fg)),
      ),
    );
  }
}
