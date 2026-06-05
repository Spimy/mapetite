import '../models/restaurant_model.dart';
import '../models/mocks/restaurant_mocks.dart';

class RestaurantService {
  Future<List<RestaurantModel>> getNearbyRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return RestaurantMocks.nearbyRestaurants;
    // TODO: Replace with real API call to GET /api/v1/restaurants/nearby
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return RestaurantMocks.nearbyRestaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
    // TODO: Replace with real API call to GET /api/v1/restaurants/:id
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return RestaurantMocks.nearbyRestaurants
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    // TODO: Replace with real API call to GET /api/v1/restaurants/search?q=:query
  }
}
