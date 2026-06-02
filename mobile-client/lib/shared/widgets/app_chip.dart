import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_constants.dart';
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
  final Widget? leadingIcon;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
    this.onTap,
    this.style = AppChipStyle.filter,
    this.leadingIcon,
  });

  factory AppChip.halal({VoidCallback? onTap}) => AppChip(
        label: 'Halal',
        backgroundColor: AppColors.tagHalal,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        leadingIcon: SvgPicture.asset(
          'assets/icons/dietary/halal-icon.svg',
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
        onTap: onTap,
      );

  factory AppChip.vegan({VoidCallback? onTap}) => AppChip(
        label: 'Vegan',
        backgroundColor: AppColors.tagVegan,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        leadingIcon: const Icon(Icons.eco, size: 11, color: AppColors.white),
        onTap: onTap,
      );

  factory AppChip.vegetarian({VoidCallback? onTap}) => AppChip(
        label: 'Vegetarian',
        backgroundColor: AppColors.tagVegetarian,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        leadingIcon: const Icon(Icons.spa, size: 11, color: AppColors.white),
        onTap: onTap,
      );

  static const Map<String, IconData> allergenIconMap = {
    'Nuts': Icons.park,
    'Dairy': Icons.water_drop,
    'Gluten': Icons.grain,
    'Shellfish': Icons.waves,
    'Eggs': Icons.egg,
    'Soy': Icons.eco,
  };

  factory AppChip.allergen(String allergen, {VoidCallback? onTap}) => AppChip(
        label: allergen,
        backgroundColor: AppColors.tagAllergen,
        textColor: AppColors.white,
        style: AppChipStyle.dietary,
        leadingIcon: Icon(
          allergenIconMap[allergen] ?? Icons.warning_amber,
          size: 11,
          color: AppColors.white,
        ),
        onTap: onTap,
      );

  factory AppChip.cuisine(String cuisine, {VoidCallback? onTap}) => AppChip(
        label: cuisine,
        backgroundColor: AppColors.neutral100,
        textColor: AppColors.neutral700,
        style: AppChipStyle.category,
        leadingIcon: Icon(
          AppConstants.cuisineIcons[cuisine] ?? Icons.restaurant_menu,
          size: 11,
          color: AppColors.neutral700,
        ),
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
        child: leadingIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  leadingIcon!,
                  const SizedBox(width: 3),
                  Text(label, style: AppTypography.label.copyWith(color: fg)),
                ],
              )
            : Text(label, style: AppTypography.label.copyWith(color: fg)),
      ),
    );
  }
}
