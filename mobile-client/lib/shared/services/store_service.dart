import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/store_item_model.dart';
import '../models/store_model.dart';

class StoreService {
  Future<List<StoreModel>> getStores({StoreType? type}) async {
    final response = await ApiClient.get(
      ApiEndpoints.stores,
      params: {if (type != null) 'type': type.apiValue},
    );
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(StoreModel.fromJson).toList();
  }

  Future<List<StoreModel>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 5,
    StoreType? type,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.storesNearby,
      params: {
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
        if (type != null) 'type': type.apiValue,
      },
    );
    final results = response.data['results'] as List<dynamic>;
    return results.cast<Map<String, dynamic>>().map(StoreModel.fromJson).toList();
  }

  Future<StoreModel> getStoreDetail(String id) async {
    final response = await ApiClient.get(ApiEndpoints.storeDetail(id));
    return StoreModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<StoreItemModel>> getStoreItems(String id) async {
    final response = await ApiClient.get(ApiEndpoints.storeItems(id));
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(StoreItemModel.fromJson).toList();
  }
}
