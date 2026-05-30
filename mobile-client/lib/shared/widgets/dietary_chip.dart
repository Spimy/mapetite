import 'package:flutter/material.dart';
import 'app_chip.dart';

enum DietaryTag { halal, vegan, vegetarian, allergen }

class DietaryChip extends StatelessWidget {
  final DietaryTag tag;

  const DietaryChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return switch (tag) {
      DietaryTag.halal => AppChip.halal(),
      DietaryTag.vegan => AppChip.vegan(),
      DietaryTag.vegetarian => AppChip.vegetarian(),
      DietaryTag.allergen => AppChip.allergen('Allergen'),
    };
  }
}
