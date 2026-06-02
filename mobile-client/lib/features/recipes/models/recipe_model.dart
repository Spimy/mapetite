enum RecipeVisibility { public, private }

enum RecipeSortOption { newest, mostPopular, lowestCalorie, quickest }

enum RecipeFilter { halal, vegan, vegetarian, under30min, myRecipes }

class RecipeIngredient {
  final String name;
  final String quantity;
  final String? storeName;
  final double? estimatedCost;
  final bool notSourcedNearby;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    this.storeName,
    this.estimatedCost,
    this.notSourcedNearby = false,
  });
}

class RecipeStep {
  final int stepNumber;
  final String description;

  const RecipeStep({required this.stepNumber, required this.description});
}

class RecipeModel {
  final String id;
  final String title;
  final String? description;
  final String authorName;
  final String authorInitial;
  final String postedAgo;
  final int cookMinutes;
  final int calories;
  final int servings;
  final bool isHalal;
  final bool isVegan;
  final bool isVegetarian;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final RecipeVisibility visibility;
  final int saves;
  final bool isOwnedByCurrentUser;
  final DateTime createdAt;

  const RecipeModel({
    required this.id,
    required this.title,
    this.description,
    required this.authorName,
    required this.authorInitial,
    required this.postedAgo,
    required this.cookMinutes,
    required this.calories,
    required this.servings,
    this.isHalal = false,
    this.isVegan = false,
    this.isVegetarian = false,
    required this.ingredients,
    required this.steps,
    this.visibility = RecipeVisibility.public,
    this.saves = 0,
    this.isOwnedByCurrentUser = false,
    required this.createdAt,
  });
}
