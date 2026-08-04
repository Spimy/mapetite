import '../../../shared/models/store_model.dart';

class RestaurantRecommendation {
  final StoreModel store;
  final double matchScore;
  final List<String> reasons;
  final double? distanceKm;
  final String? pricingBracket;
  final bool? isOpen;
  final double? averagePrice;
  final double? averageCalories;
  final String? recommendationReason;

  const RestaurantRecommendation({
    required this.store,
    required this.matchScore,
    this.reasons = const [],
    this.distanceKm,
    this.pricingBracket,
    this.isOpen,
    this.averagePrice,
    this.averageCalories,
    this.recommendationReason,
  });

  factory RestaurantRecommendation.fromJson(Map<String, dynamic> json) {
    final storeJson = json['store'];

    if (storeJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Recommendation response is missing store data.',
      );
    }

    return RestaurantRecommendation(
      store: StoreModel.fromJson(storeJson),
      matchScore: _doubleFromJson(json['match_score']) ?? 0,
      reasons: (json['reasons'] as List<dynamic>? ?? const <dynamic>[])
          .map((reason) => reason.toString())
          .where((reason) => reason.trim().isNotEmpty)
          .toList(),
      distanceKm: _doubleFromJson(json['distance_km']),
      pricingBracket: json['pricing_bracket']?.toString(),
      isOpen: json['is_open'] as bool?,
      averagePrice: _doubleFromJson(json['avg_price']),
      averageCalories: _doubleFromJson(json['avg_calories']),
      recommendationReason: json['recommendation_reason']?.toString(),
    );
  }

  String get matchPercentText {
    final percent = matchScore <= 1 ? matchScore * 100 : matchScore;
    return '${percent.round()}% match';
  }
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}