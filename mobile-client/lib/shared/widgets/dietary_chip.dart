import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';
import 'app_chip.dart';

enum DietaryTag { halal, vegan, vegetarian, allergen }

class DietaryChip extends StatelessWidget {
  // Used by the base constructor (tag-based path).
  final DietaryTag? _tag;

  // Used by named constructors (direct value path).
  final String? _label;
  final bool _outlined;

  const DietaryChip({super.key, required DietaryTag tag})
      : _tag = tag,
        _label = null,
        _outlined = false;

  const DietaryChip.halal({super.key})
      : _tag = null,
        _label = 'Halal',
        _outlined = false;

  const DietaryChip.vegan({super.key})
      : _tag = null,
        _label = 'Vegan',
        _outlined = false;

  const DietaryChip.vegetarian({super.key})
      : _tag = null,
        _label = 'Vegetarian',
        _outlined = false;

  const DietaryChip.allergen(String label, {super.key})
      : _tag = null,
        _label = label,
        _outlined = false;

  const DietaryChip.restriction(String label, {super.key})
      : _tag = null,
        _label = label,
        _outlined = true;

  @override
  Widget build(BuildContext context) {
    // Tag-based path (base constructor): delegate to AppChip factories.
    if (_tag != null) {
      return switch (_tag) {
        DietaryTag.halal => AppChip.halal(),
        DietaryTag.vegan => AppChip.vegan(),
        DietaryTag.vegetarian => AppChip.vegetarian(),
        DietaryTag.allergen => AppChip.allergen('Allergen'),
      };
    }

    // _label is always non-null when _tag is null (all non-tag constructors set it)
    final label = _label!;

    // Outlined (restriction) path.
    if (_outlined) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.neutral600, width: 1),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.neutral600),
        ),
      );
    }

    // Named constructor path: route by label to AppChip factories.
    return switch (label) {
      'Halal' => AppChip.halal(),
      'Vegan' => AppChip.vegan(),
      'Vegetarian' => AppChip.vegetarian(),
      _ => AppChip.allergen(label),
    };
  }
}
