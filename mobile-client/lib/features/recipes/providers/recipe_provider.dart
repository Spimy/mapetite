import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/auth/controllers/auth_controller.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

enum CalorieRange {
  low,
  medium,
  high,
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
      calorieRange:
          clearCalorieRange ? null : calorieRange ?? this.calorieRange,
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

  void setSort(RecipeSortOption option) {
    state = state.copyWith(sortOption: option);
  }

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

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

final recipeLoadingProvider = StateProvider<bool>((ref) => false);
final recipeErrorProvider = StateProvider<String?>((ref) => null);

class RecipeListNotifier extends StateNotifier<List<RecipeModel>> {
  final Ref _ref;
  final RecipeService _recipeService;

  RecipeListNotifier(this._ref, this._recipeService) : super(const []) {
    loadRecipes();
  }

  int? get _currentUserId {
    return _ref.read(authControllerProvider).currentUser?.id;
  }

  Future<void> loadRecipes({String? query}) async {
    _ref.read(recipeLoadingProvider.notifier).state = true;
    _ref.read(recipeErrorProvider.notifier).state = null;

    try {
      final recipes = await _recipeService.getRecipes(
        query: query,
        currentUserId: _currentUserId,
      );

      state = recipes;
    } catch (_) {
      _ref.read(recipeErrorProvider.notifier).state =
          'Unable to load recipes. Please try again.';
    } finally {
      _ref.read(recipeLoadingProvider.notifier).state = false;
    }
  }

  Future<RecipeModel?> loadRecipeById(String id) async {
    try {
      final recipe = await _recipeService.getRecipeById(
        id,
        currentUserId: _currentUserId,
      );

      _upsert(recipe);
      return recipe;
    } catch (_) {
      return null;
    }
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    final previous = state;

    try {
      final created = await _recipeService.createRecipe(
        recipe,
        currentUserId: _currentUserId,
      );

      state = [created, ...state];
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> updateRecipe(RecipeModel updated) async {
    final previous = state;

    state = state.map((recipe) {
      return recipe.id == updated.id ? updated : recipe;
    }).toList();

    try {
      final saved = await _recipeService.updateRecipe(
        updated,
        currentUserId: _currentUserId,
      );

      _upsert(saved);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    final previous = state;

    state = state.where((recipe) => recipe.id != id).toList();

    try {
      await _recipeService.deleteRecipe(id);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  void _upsert(RecipeModel recipe) {
    final exists = state.any((item) => item.id == recipe.id);

    if (exists) {
      state = state.map((item) {
        return item.id == recipe.id ? recipe : item;
      }).toList();
    } else {
      state = [recipe, ...state];
    }
  }
}

final recipeListProvider =
    StateNotifierProvider<RecipeListNotifier, List<RecipeModel>>(
  (ref) => RecipeListNotifier(ref, ref.read(recipeServiceProvider)),
);

final filteredRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final filterState = ref.watch(recipeFilterProvider);
  final savedIds = ref.watch(savedRecipeIdsProvider);
  var recipes = List<RecipeModel>.from(ref.watch(recipeListProvider));

  final q = filterState.searchQuery.toLowerCase();

  if (q.isNotEmpty) {
    recipes = recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(q) ||
          (recipe.description?.toLowerCase().contains(q) ?? false) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.name.toLowerCase().contains(q),
          );
    }).toList();
  }

  for (final filter in filterState.activeFilters) {
    switch (filter) {
      case RecipeFilter.halal:
        recipes = recipes.where((recipe) => recipe.isHalal).toList();
      case RecipeFilter.vegan:
        recipes = recipes.where((recipe) => recipe.isVegan).toList();
      case RecipeFilter.vegetarian:
        recipes = recipes.where((recipe) => recipe.isVegetarian).toList();
      case RecipeFilter.under30min:
        recipes = recipes.where((recipe) => recipe.cookMinutes <= 30).toList();
      case RecipeFilter.myRecipes:
        recipes =
            recipes.where((recipe) => recipe.isOwnedByCurrentUser).toList();
      case RecipeFilter.saved:
        recipes = recipes.where((recipe) => savedIds.contains(recipe.id)).toList();
    }
  }

  if (filterState.calorieRange != null) {
    switch (filterState.calorieRange!) {
      case CalorieRange.low:
        recipes = recipes
            .where((recipe) => recipe.calories > 0 && recipe.calories < 300)
            .toList();
      case CalorieRange.medium:
        recipes = recipes
            .where((recipe) =>
                recipe.calories >= 300 && recipe.calories <= 500)
            .toList();
      case CalorieRange.high:
        recipes =
            recipes.where((recipe) => recipe.calories > 500).toList();
    }
  }

  if (filterState.activeCuisines.isNotEmpty) {
    recipes = recipes.where((recipe) {
      return filterState.activeCuisines.contains(recipe.cuisine);
    }).toList();
  }

  for (final allergen in filterState.allergenFreeFilters) {
    recipes = recipes.where((recipe) {
      return !recipe.allergens.contains(allergen);
    }).toList();
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
  return ref.watch(recipeListProvider).where((recipe) => recipe.id == id).firstOrNull;
});

final savedRecipeIdsProvider =
    StateNotifierProvider<SavedRecipesNotifier, Set<String>>(
  (ref) => SavedRecipesNotifier(ref, ref.read(recipeServiceProvider)),
);

class SavedRecipesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  final RecipeService _recipeService;

  SavedRecipesNotifier(this._ref, this._recipeService) : super({});

  int? get _currentUserId {
    return _ref.read(authControllerProvider).currentUser?.id;
  }

  Future<void> toggle(String recipeId) async {
    final wasSaved = state.contains(recipeId);
    final previous = state;

    final updated = Set<String>.from(state);

    if (wasSaved) {
      updated.remove(recipeId);
    } else {
      updated.add(recipeId);
    }

    state = updated;

    try {
      final recipe = wasSaved
          ? await _recipeService.unsaveRecipe(
              recipeId,
              currentUserId: _currentUserId,
            )
          : await _recipeService.saveRecipe(
              recipeId,
              currentUserId: _currentUserId,
            );

      _ref.read(recipeListProvider.notifier)._upsert(recipe);
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  bool isSaved(String recipeId) => state.contains(recipeId);
}