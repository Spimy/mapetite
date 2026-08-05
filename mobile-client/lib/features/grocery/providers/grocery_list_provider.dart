import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/storage_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/current_user.dart';
import '../models/grocery_list_model.dart';
import '../models/mocks/grocery_list_mocks.dart';

class GroceryListNotifier extends StateNotifier<List<GroceryListItem>> {
  GroceryListNotifier() : super([]);

  static const String _storageKeyPrefix = 'grocery_list_';

  String? _activeUserKey;

  void loadForUser(String? userKey) {
    if (_activeUserKey == userKey) {
      return;
    }

    _activeUserKey = userKey;

    if (userKey == null || userKey.isEmpty) {
      state = [];
      return;
    }

    final storageKey = _storageKeyForUser(userKey);
    final storedList = StorageService.getString(storageKey);

    if (storedList == null || storedList.isEmpty) {
      state = [];
      return;
    }

    try {
      final decoded = jsonDecode(storedList);

      if (decoded is! List) {
        state = [];
        return;
      }

      state = decoded
          .whereType<Map>()
          .map(
            (item) => GroceryListItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      state = [];
      unawaited(StorageService.remove(storageKey));
    }
  }

  void toggleItem(String id) {
    _setItems(
      state.map((item) {
        if (item.id == id) {
          return item.copyWith(isChecked: !item.isChecked);
        }

        return item;
      }).toList(),
    );
  }

  void addItem(GroceryListItem item) {
    _setItems([...state, item]);
  }

  void removeItem(String id) {
    _setItems(state.where((item) => item.id != id).toList());
  }

  void clearCompleted() {
    _setItems(state.where((item) => !item.isChecked).toList());
  }

  void clearAll() {
    _setItems([]);
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

    _setItems([...state, ...newItems]);
  }

  void addFromList(List<GroceryListItem> items) {
    _setItems([...state, ...items]);
  }

  void linkItemsToStore({
    required Set<String> itemNames,
    required String storeId,
    required String storeName,
    required double? storeLatitude,
    required double? storeLongitude,
  }) {
    final normalisedNames = itemNames.map(_normaliseItemName).toSet();

    _setItems(
      state.map((item) {
        if (!normalisedNames.contains(_normaliseItemName(item.name))) {
          return item;
        }

        return item.copyWith(
          storeName: storeName,
          storeId: storeId,
          storeLatitude: storeLatitude,
          storeLongitude: storeLongitude,
        );
      }).toList(),
    );
  }

  void _setItems(List<GroceryListItem> items) {
    state = items;
    _persistItems(items);
  }

  void _persistItems(List<GroceryListItem> items) {
    final userKey = _activeUserKey;

    if (userKey == null || userKey.isEmpty) {
      return;
    }

    final encoded = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );

    unawaited(
      StorageService.setString(_storageKeyForUser(userKey), encoded),
    );
  }

  String _storageKeyForUser(String userKey) {
    return '$_storageKeyPrefix$userKey';
  }
}

final groceryListProvider =
    StateNotifierProvider<GroceryListNotifier, List<GroceryListItem>>(
  (ref) {
    final notifier = GroceryListNotifier();

    notifier.loadForUser(
      _storageKeyForCurrentUser(ref.read(authControllerProvider).currentUser),
    );

    ref.listen(
      authControllerProvider.select(
        (state) => _storageKeyForCurrentUser(state.currentUser),
      ),
      (_, nextUserKey) {
        notifier.loadForUser(nextUserKey);
      },
    );

    return notifier;
  },
);

final groceryTotalProvider = Provider<double>((ref) {
  final items = ref.watch(groceryListProvider);

  return items.fold(0.0, (sum, item) => sum + item.estimatedPrice);
});

final groceryBudgetAlertProvider = Provider<bool>((ref) {
  final total = ref.watch(groceryTotalProvider);

  return total >= GroceryListMocks.weeklyBudgetLimit * 0.80;
});

String? _storageKeyForCurrentUser(CurrentUser? user) {
  if (user == null) {
    return null;
  }

  if (user.id > 0) {
    return 'user_${user.id}';
  }

  final email = user.email.trim().toLowerCase();

  if (email.isNotEmpty) {
    return 'email_$email';
  }

  return null;
}

String _normaliseItemName(String value) {
  return value.trim().toLowerCase();
}