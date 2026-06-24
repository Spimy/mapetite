import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedIngredient {
  final String name;
  final String quantity;
  final String? storeName;
  final double cost;

  const SelectedIngredient({
    required this.name,
    required this.quantity,
    this.storeName,
    this.cost = 0.0,
  });
}

final selectedIngredientsProvider =
    StateProvider<List<SelectedIngredient>>((ref) => []);
