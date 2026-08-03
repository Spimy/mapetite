import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grocery_list_model.dart';
import '../models/mocks/grocery_list_mocks.dart';

class GroceryListNotifier extends StateNotifier<List<GroceryListItem>> {
  GroceryListNotifier() : super([]);

  void toggleItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: !item.isChecked);
      }

      return item;
    }).toList();
  }

  void addItem(GroceryListItem item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((item) => !item.isChecked).toList();
  }

  void clearAll() {
    state = [];
  }

  void addFromIngredients(
    List<({String name, String quantity, String storeName, double cost})>
        ingredients,
  ) {
    final base = DateTime.now().millisecondsSinceEpoch;

    final newItems = ingredients.indexed.map((entry) {
      final (index, ingredient) = entry;

      return GroceryListItem(
        id: 'g_${base}_$index',
        name: ingredient.name,
        quantity: ingredient.quantity,
        storeName: ingredient.storeName,
        estimatedPrice: ingredient.cost,
      );
    }).toList();

    state = [...state, ...newItems];
  }

  void addFromList(List<GroceryListItem> items) {
    state = [...state, ...items];
  }
}

final groceryListProvider =
    StateNotifierProvider<GroceryListNotifier, List<GroceryListItem>>(
  (_) => GroceryListNotifier(),
);

final groceryTotalProvider = Provider<double>((ref) {
  final items = ref.watch(groceryListProvider);

  return items.fold(0.0, (sum, item) => sum + item.estimatedPrice);
});

final groceryBudgetAlertProvider = Provider<bool>((ref) {
  final total = ref.watch(groceryTotalProvider);

  return total >= GroceryListMocks.weeklyBudgetLimit * 0.80;
});