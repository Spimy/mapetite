import '../models/restaurant_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class RestaurantService {
  Future<List<RestaurantModel>> getNearbyRestaurants() async {
    final response = await ApiClient.get(ApiEndpoints.restaurants);
    final data = response.data as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(RestaurantModel.fromJson)
        .toList();
  }

  Future<RestaurantModel?> getRestaurantById(String id) async {
    final response = await ApiClient.get(ApiEndpoints.restaurant(id));
    return RestaurantModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final all = await getNearbyRestaurants();
    final q = query.toLowerCase();
    return all
        .where((r) => r.name.toLowerCase().contains(q))
        .toList();
  }
}
