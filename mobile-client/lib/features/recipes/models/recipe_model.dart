enum RecipeVisibility { public, private }

enum RecipeSortOption { newest, mostPopular, lowestCalorie, quickest }

enum RecipeFilter { halal, vegan, vegetarian, under30min, myRecipes, saved }

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
  final int cookMinutes;
  final int calories;
  final int servings;
  final bool isHalal;
  final bool isVegan;
  final bool isVegetarian;
  final String? cuisine;
  final List<String> allergens;
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
    required this.cookMinutes,
    required this.calories,
    required this.servings,
    this.isHalal = false,
    this.isVegan = false,
    this.isVegetarian = false,
    this.cuisine,
    this.allergens = const [],
    required this.ingredients,
    required this.steps,
    this.visibility = RecipeVisibility.public,
    this.saves = 0,
    this.isOwnedByCurrentUser = false,
    required this.createdAt,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    if (diff.inHours < 24)   return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays == 1)    return 'Yesterday';
    if (diff.inDays < 7)     return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inDays < 14)    return '1 week ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }
}
