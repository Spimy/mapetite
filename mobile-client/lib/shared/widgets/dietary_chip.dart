import 'package:flutter/material.dart';
import 'app_chip.dart';

enum DietaryTag { halal, vegan, vegetarian, allergen }

class DietaryChip extends StatelessWidget {
  // Used by the base constructor (tag-based path).
  final DietaryTag? _tag;

  // Used by named constructors (direct value path).
  final String? _label;
  final Color? _bgColor;
  final Color? _textColor;
  final bool _outlined;

  const DietaryChip({super.key, required DietaryTag tag})
      : _tag = tag,
        _label = null,
        _bgColor = null,
        _textColor = null,
        _outlined = false;

  const DietaryChip.halal({super.key})
      : _tag = null,
        _label = 'Halal',
        _bgColor = const Color(0xFF065F46),
        _textColor = const Color(0xFFFFFFFF),
        _outlined = false;

  const DietaryChip.vegan({super.key})
      : _tag = null,
        _label = 'Vegan',
        _bgColor = const Color(0xFF0E7490),
        _textColor = const Color(0xFFFFFFFF),
        _outlined = false;

  const DietaryChip.vegetarian({super.key})
      : _tag = null,
        _label = 'Vegetarian',
        _bgColor = const Color(0xFF10B981),
        _textColor = const Color(0xFFFFFFFF),
        _outlined = false;

  const DietaryChip.allergen(String label, {super.key})
      : _tag = null,
        _label = label,
        _bgColor = const Color(0xFFF59E0B),
        _textColor = const Color(0xFFFFFFFF),
        _outlined = false;

  const DietaryChip.restriction(String label, {super.key})
      : _tag = null,
        _label = label,
        _bgColor = const Color(0x00000000),
        _textColor = const Color(0xFF6B7280),
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

    final label = _label!;

    // Outlined (restriction) path.
    if (_outlined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF6B7280), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.02 * 11,
          ),
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
