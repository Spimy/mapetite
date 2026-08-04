import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/restaurant_recommendation_model.dart';

class RecommendationService {
  Future<RestaurantRecommendation> getTopPick({
    required double lat,
    required double lng,
    double? radiusKm,
    bool? openNow,
    bool? strict,
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
}