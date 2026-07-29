enum RecipeVisibility { public, private }

enum RecipeSortOption { newest, mostPopular, lowestCalorie, quickest }

enum RecipeFilter { halal, vegan, vegetarian, under30min, myRecipes, saved }

class RecipeIngredient {
  final String name;
  final String quantity;
  final String? unit;
  final String? storeName;
  final double? estimatedCost;
  final bool notSourcedNearby;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    this.unit,
    this.storeName,
    this.estimatedCost,
    this.notSourcedNearby = false,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity']?.toString() ?? '1';
    final unit = json['unit']?.toString();

    return RecipeIngredient(
      name: json['name']?.toString() ?? '',
      quantity: unit == null || unit.isEmpty ? quantity : '$quantity $unit',
      unit: unit,
    );
  }

  Map<String, dynamic> toRequestJson() {
    final parsed = _parseQuantityAndUnit(quantity, unit);

    return {
      'name': name.trim(),
      'quantity': parsed.quantity,
      'unit': parsed.unit,
    };
  }
}

class RecipeStep {
  final int stepNumber;
  final String description;

  const RecipeStep({
    required this.stepNumber,
    required this.description,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 1,
      description: json['instruction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'step_number': stepNumber,
      'instruction': description.trim(),
    };
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String authorName;
  final String authorInitial;
  final int? authorId;
  final int cookMinutes;
  final int calories;
  final int servings;
  final bool isHalal;
  final bool isVegan;
  final bool isVegetarian;
  final bool isGlutenFree;
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
    this.thumbnailUrl,
    required this.authorName,
    required this.authorInitial,
    this.authorId,
    required this.cookMinutes,
    required this.calories,
    required this.servings,
    this.isHalal = false,
    this.isVegan = false,
    this.isVegetarian = false,
    this.isGlutenFree = false,
    this.cuisine,
    this.allergens = const [],
    required this.ingredients,
    required this.steps,
    this.visibility = RecipeVisibility.public,
    this.saves = 0,
    this.isOwnedByCurrentUser = false,
    required this.createdAt,
  });

  factory RecipeModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    final author = json['author'];
    final authorMap = author is Map<String, dynamic> ? author : null;

    final authorName = authorMap?['name']?.toString() ?? 'Unknown';
    final authorId = (authorMap?['id'] as num?)?.toInt();

    final ingredients = (json['ingredients'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(RecipeIngredient.fromJson)
        .toList();

    final steps = (json['steps'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(RecipeStep.fromJson)
        .toList();

    return RecipeModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      thumbnailUrl: json['thumbnail']?.toString(),
      authorName: authorName,
      authorInitial: authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
      authorId: authorId,
      cookMinutes: (json['prep_time'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      isHalal: json['is_halal'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      ingredients: ingredients,
      steps: steps,
      saves: (json['saves_count'] as num?)?.toInt() ?? 0,
      isOwnedByCurrentUser:
          currentUserId != null && authorId != null && currentUserId == authorId,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? authorName,
    String? authorInitial,
    int? authorId,
    int? cookMinutes,
    int? calories,
    int? servings,
    bool? isHalal,
    bool? isVegan,
    bool? isVegetarian,
    bool? isGlutenFree,
    String? cuisine,
    List<String>? allergens,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    RecipeVisibility? visibility,
    int? saves,
    bool? isOwnedByCurrentUser,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorName: authorName ?? this.authorName,
      authorInitial: authorInitial ?? this.authorInitial,
      authorId: authorId ?? this.authorId,
      cookMinutes: cookMinutes ?? this.cookMinutes,
      calories: calories ?? this.calories,
      servings: servings ?? this.servings,
      isHalal: isHalal ?? this.isHalal,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      cuisine: cuisine ?? this.cuisine,
      allergens: allergens ?? this.allergens,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      visibility: visibility ?? this.visibility,
      saves: saves ?? this.saves,
      isOwnedByCurrentUser:
          isOwnedByCurrentUser ?? this.isOwnedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title.trim(),
      'prep_time': cookMinutes,
      'servings': servings,
      'calories': calories,
      'is_halal': isHalal,
      'is_vegan': isVegan,
      'is_vegetarian': isVegetarian,
      'is_gluten_free': isGlutenFree,
      'ingredients': ingredients.map((item) => item.toRequestJson()).toList(),
      'steps': steps.map((step) => step.toRequestJson()).toList(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 14) return '1 week ago';

    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }
}

({String quantity, String unit}) _parseQuantityAndUnit(
  String value, [
  String? selectedUnit,
]) {
  final trimmed = value.trim();
  final explicitUnit = selectedUnit?.trim();

  String resolveUnit(String parsedUnit) {
    if (explicitUnit != null && explicitUnit.isNotEmpty) {
      return _normaliseUnit(explicitUnit);
    }

    return _normaliseUnit(parsedUnit);
  }

  if (trimmed.isEmpty) {
    return (quantity: '1', unit: resolveUnit(''));
  }

  final mixedFractionMatch =
      RegExp(r'^(\d+)\s+(\d+)\/(\d+)(?:\s+(.+))?$').firstMatch(trimmed);

  if (mixedFractionMatch != null) {
    final whole = double.tryParse(mixedFractionMatch.group(1)!);
    final numerator = double.tryParse(mixedFractionMatch.group(2)!);
    final denominator = double.tryParse(mixedFractionMatch.group(3)!);
    final parsedUnit = mixedFractionMatch.group(4) ?? '';

    if (whole != null &&
        numerator != null &&
        denominator != null &&
        denominator != 0) {
      return (
        quantity: _formatQuantityNumber(whole + (numerator / denominator)),
        unit: resolveUnit(parsedUnit),
      );
    }
  }

  final fractionMatch =
      RegExp(r'^(\d+)\/(\d+)(?:\s+(.+))?$').firstMatch(trimmed);

  if (fractionMatch != null) {
    final numerator = double.tryParse(fractionMatch.group(1)!);
    final denominator = double.tryParse(fractionMatch.group(2)!);
    final parsedUnit = fractionMatch.group(3) ?? '';

    if (numerator != null && denominator != null && denominator != 0) {
      return (
        quantity: _formatQuantityNumber(numerator / denominator),
        unit: resolveUnit(parsedUnit),
      );
    }
  }

  final decimalMatch =
      RegExp(r'^(\d+(?:\.\d+)?)(?:\s+(.+))?$').firstMatch(trimmed);

  if (decimalMatch != null) {
    return (
      quantity: decimalMatch.group(1)!,
      unit: resolveUnit(decimalMatch.group(2) ?? ''),
    );
  }

  return (quantity: '1', unit: resolveUnit(trimmed));
}

String _formatQuantityNumber(double value) {
  final rounded = value.toStringAsFixed(4);
  final withoutTrailingZeros =
      rounded.replaceFirst(RegExp(r'\.?0+$'), '');

  return withoutTrailingZeros.isEmpty ? '0' : withoutTrailingZeros;
}

String _normaliseUnit(String unit) {
  final value = unit.trim();

  const allowed = {
    'g',
    'kg',
    'ml',
    'L',
    'pcs',
    'tbsp',
    'tsp',
    'cup',
  };

  if (allowed.contains(value)) {
    return value;
  }

  final lower = value.toLowerCase();

  if (lower == 'l') return 'L';
  if (lower == 'piece' || lower == 'pieces' || lower == 'pc') return 'pcs';
  if (lower == 'tablespoon' || lower == 'tablespoons') return 'tbsp';
  if (lower == 'teaspoon' || lower == 'teaspoons') return 'tsp';
  if (lower == 'cups') return 'cup';

  return 'pcs';
}