import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe_model.dart';
import '../models/mocks/recipe_mocks.dart';

enum CalorieRange {
  low,    // < 300 kcal
  medium, // 300–500 kcal
  high,   // > 500 kcal
}

class RecipeFilterState {
  final String searchQuery;
  final Set<RecipeFilter> activeFilters;
  final RecipeSortOption sortOption;
  final Set<String> activeCuisines;
  final Set<String> allergenFreeFilters;
  final CalorieRange? calorieRange;

  const RecipeFilterState({
    this.searchQuery = '',
    this.activeFilters = const {},
    this.sortOption = RecipeSortOption.newest,
    this.activeCuisines = const {},
    this.allergenFreeFilters = const {},
    this.calorieRange,
  });

  RecipeFilterState copyWith({
    String? searchQuery,
    Set<RecipeFilter>? activeFilters,
    RecipeSortOption? sortOption,
    Set<String>? activeCuisines,
    Set<String>? allergenFreeFilters,
    CalorieRange? calorieRange,
    bool clearCalorieRange = false,
  }) {
    return RecipeFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      sortOption: sortOption ?? this.sortOption,
      activeCuisines: activeCuisines ?? this.activeCuisines,
      allergenFreeFilters: allergenFreeFilters ?? this.allergenFreeFilters,
      calorieRange: clearCalorieRange ? null : (calorieRange ?? this.calorieRange),
    );
  }
}

class RecipeFilterNotifier extends StateNotifier<RecipeFilterState> {
  RecipeFilterNotifier() : super(const RecipeFilterState());

  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  void toggleFilter(RecipeFilter filter) {
    final updated = Set<RecipeFilter>.from(state.activeFilters);
    if (updated.contains(filter)) {
      updated.remove(filter);
    } else {
      updated.add(filter);
    }
    state = state.copyWith(activeFilters: updated);
  }

  void setSort(RecipeSortOption option) => state = state.copyWith(sortOption: option);

  void toggleCuisine(String cuisine) {
    final updated = Set<String>.from(state.activeCuisines);
    if (updated.contains(cuisine)) {
      updated.remove(cuisine);
    } else {
      updated.add(cuisine);
    }
    state = state.copyWith(activeCuisines: updated);
  }

  void toggleAllergenFree(String allergen) {
    final updated = Set<String>.from(state.allergenFreeFilters);
    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }
    state = state.copyWith(allergenFreeFilters: updated);
  }

  void setCalorieRange(CalorieRange? range) {
    if (range == null || range == state.calorieRange) {
      state = state.copyWith(clearCalorieRange: true);
    } else {
      state = state.copyWith(calorieRange: range);
    }
  }

  void clearFilters() => state = const RecipeFilterState();
}

final recipeFilterProvider =
    StateNotifierProvider<RecipeFilterNotifier, RecipeFilterState>(
  (_) => RecipeFilterNotifier(),
);

class RecipeListNotifier extends StateNotifier<List<RecipeModel>> {
  RecipeListNotifier() : super(List<RecipeModel>.from(RecipeMocks.all));

  void addRecipe(RecipeModel recipe) {
    state = [recipe, ...state];
  }

  void updateRecipe(RecipeModel updated) {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
  }
}

final recipeListProvider =
    StateNotifierProvider<RecipeListNotifier, List<RecipeModel>>(
  (_) => RecipeListNotifier(),
);

final filteredRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final filterState = ref.watch(recipeFilterProvider);
  final savedIds = ref.watch(savedRecipeIdsProvider);
  var recipes = List<RecipeModel>.from(ref.watch(recipeListProvider));

  final q = filterState.searchQuery.toLowerCase();
  if (q.isNotEmpty) {
    recipes = recipes.where((r) {
      return r.title.toLowerCase().contains(q) ||
          (r.description?.toLowerCase().contains(q) ?? false) ||
          r.ingredients.any((i) => i.name.toLowerCase().contains(q));
    }).toList();
  }

  for (final filter in filterState.activeFilters) {
    switch (filter) {
      case RecipeFilter.halal:
        recipes = recipes.where((r) => r.isHalal).toList();
      case RecipeFilter.vegan:
        recipes = recipes.where((r) => r.isVegan).toList();
      case RecipeFilter.vegetarian:
        recipes = recipes.where((r) => r.isVegetarian).toList();
      case RecipeFilter.under30min:
        recipes = recipes.where((r) => r.cookMinutes <= 30).toList();
      case RecipeFilter.myRecipes:
        recipes = recipes.where((r) => r.isOwnedByCurrentUser).toList();
      case RecipeFilter.saved:
        recipes = recipes.where((r) => savedIds.contains(r.id)).toList();
    }
  }

  if (filterState.calorieRange != null) {
    switch (filterState.calorieRange!) {
      case CalorieRange.low:
        recipes = recipes.where((r) => r.calories > 0 && r.calories < 300).toList();
      case CalorieRange.medium:
        recipes = recipes.where((r) => r.calories >= 300 && r.calories <= 500).toList();
      case CalorieRange.high:
        recipes = recipes.where((r) => r.calories > 500).toList();
    }
  }

  if (filterState.activeCuisines.isNotEmpty) {
    recipes = recipes.where((r) => filterState.activeCuisines.contains(r.cuisine)).toList();
  }

  for (final allergen in filterState.allergenFreeFilters) {
    recipes = recipes.where((r) => !r.allergens.contains(allergen)).toList();
  }

  switch (filterState.sortOption) {
    case RecipeSortOption.newest:
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case RecipeSortOption.mostPopular:
      recipes.sort((a, b) => b.saves.compareTo(a.saves));
    case RecipeSortOption.lowestCalorie:
      recipes.sort((a, b) => a.calories.compareTo(b.calories));
    case RecipeSortOption.quickest:
      recipes.sort((a, b) => a.cookMinutes.compareTo(b.cookMinutes));
  }

  return recipes;
});

final recipeByIdProvider = Provider.family<RecipeModel?, String>((ref, id) {
  return ref.watch(recipeListProvider).where((r) => r.id == id).firstOrNull;
});

final savedRecipeIdsProvider =
    StateNotifierProvider<SavedRecipesNotifier, Set<String>>(
  (_) => SavedRecipesNotifier(),
);

class SavedRecipesNotifier extends StateNotifier<Set<String>> {
  SavedRecipesNotifier() : super({});

  void toggle(String recipeId) {
    final updated = Set<String>.from(state);
    if (updated.contains(recipeId)) {
      updated.remove(recipeId);
    } else {
      updated.add(recipeId);
    }
    state = updated;
  }

  bool isSaved(String recipeId) => state.contains(recipeId);
}
