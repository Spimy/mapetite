import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe_model.dart';
import '../models/mocks/recipe_mocks.dart';

class RecipeFilterState {
  final String searchQuery;
  final Set<RecipeFilter> activeFilters;
  final RecipeSortOption sortOption;

  const RecipeFilterState({
    this.searchQuery = '',
    this.activeFilters = const {},
    this.sortOption = RecipeSortOption.newest,
  });

  RecipeFilterState copyWith({
    String? searchQuery,
    Set<RecipeFilter>? activeFilters,
    RecipeSortOption? sortOption,
  }) {
    return RecipeFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      sortOption: sortOption ?? this.sortOption,
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
