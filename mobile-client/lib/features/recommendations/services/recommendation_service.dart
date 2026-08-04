import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/restaurant_recommendation_model.dart';

class RecommendationService {
  Future<RestaurantRecommendation> getTopPick({
    required double lat,
    required double lng,
    double? radiusKm,
    bool openNow = true,
    bool strict = true,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.recommendationTopPick,
      params: {
        'lat': lat,
        'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
        if (openNow != null) 'open_now': openNow,
        if (strict != null) 'strict': strict,
      },
    );

    return RestaurantRecommendation.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<RestaurantRecommendation>> getRestaurantRecommendations({
    required double lat,
    required double lng,
    int limit = 3,
    double? radiusKm,
    bool? openNow,
    bool? strict,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.restaurantRecommendations,
      params: {
        'lat': lat,
        'lng': lng,
        'limit': limit,
        if (radiusKm != null) 'radius': radiusKm,
        if (openNow != null) 'open_now': openNow,
        if (strict != null) 'strict': strict,
      },
    );

    final data = response.data;
    final rawList = data is List
        ? data
        : data is Map<String, dynamic>
            ? data['results'] as List<dynamic>? ?? const <dynamic>[]
            : const <dynamic>[];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(RestaurantRecommendation.fromJson)
        .take(limit)
        .toList();
  }
}