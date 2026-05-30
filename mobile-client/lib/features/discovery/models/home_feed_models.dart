import 'package:flutter/foundation.dart';

@immutable
class RestaurantSummary {
  final String id;
  final String name;
  final String cuisine;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final bool isHalal;
  final bool isVegan;
  final bool isClaimed;
  final int walkMinutes;
  final String? brtRoute;
  final String? imageUrl;
  final double matchScore;

  const RestaurantSummary({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
    required this.isHalal,
    required this.isVegan,
    required this.isClaimed,
    required this.walkMinutes,
    this.brtRoute,
    this.imageUrl,
    required this.matchScore,
  });
}

@immutable
class GrocerySummary {
  final String id;
  final String name;
  final String type;
  final double distanceKm;
  final bool isOpen;
  final bool isClaimed;
  final String? closingTime;
  final String? imageUrl;

  const GrocerySummary({
    required this.id,
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.isOpen,
    required this.isClaimed,
    this.closingTime,
    this.imageUrl,
  });
}

@immutable
class RecipeSummary {
  final String id;
  final String name;
  final String cuisine;
  final int prepMinutes;
  final int calories;
  final bool isHalal;
  final bool isVegan;
  final String authorName;
  final String? imageUrl;

  const RecipeSummary({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.prepMinutes,
    required this.calories,
    required this.isHalal,
    required this.isVegan,
    required this.authorName,
    this.imageUrl,
  });
}

@immutable
class BudgetStatus {
  final double monthlyLimit;
  final double spent;
  final String month;

  const BudgetStatus({
    required this.monthlyLimit,
    required this.spent,
    required this.month,
  });

  double get remaining => monthlyLimit - spent;
  double get percentage => (spent / monthlyLimit).clamp(0.0, 1.0);
}
