import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grocery_list_model.dart';
import '../models/mocks/grocery_list_mocks.dart';

class GroceryListNotifier extends StateNotifier<List<GroceryListItem>> {
  GroceryListNotifier() : super(List.from(GroceryListMocks.initialItems));

  void toggleItem(String id) {
    state = state.map((item) {
      if (item.id == id) return item.copyWith(isChecked: !item.isChecked);
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

  void addFromIngredients(List<({String name, String quantity, String storeName, double cost})> ingredients) {
    final newItems = ingredients.map((ing) => GroceryListItem(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}_${ing.name.hashCode}',
      name: ing.name,
      quantity: ing.quantity,
      storeName: ing.storeName,
      estimatedPrice: ing.cost,
    )).toList();
    state = [...state, ...newItems];
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
