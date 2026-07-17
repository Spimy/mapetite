import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_item_model.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

final _storeService = StoreService();

/// Parameters for [nearbyStoresProvider]. Equality/hashCode are required
/// for Riverpod's `.family` to correctly cache/refetch per distinct query.
class NearbyStoresQuery {
  final double lat;
  final double lng;
  final double radiusKm;
  final StoreType? type;

  const NearbyStoresQuery({
    required this.lat,
    required this.lng,
    this.radiusKm = 5,
    this.type,
  });

  @override
  bool operator ==(Object other) =>
      other is NearbyStoresQuery &&
      other.lat == lat &&
      other.lng == lng &&
      other.radiusKm == radiusKm &&
      other.type == type;

  @override
  int get hashCode => Object.hash(lat, lng, radiusKm, type);
}

final storesProvider =
    FutureProvider.family<List<StoreModel>, StoreType?>((ref, type) {
  return _storeService.getStores(type: type);
});

final nearbyStoresProvider =
    FutureProvider.family<List<StoreModel>, NearbyStoresQuery>((ref, query) {
  return _storeService.getNearbyStores(
    lat: query.lat,
    lng: query.lng,
    radiusKm: query.radiusKm,
    type: query.type,
  );
});

final storeDetailProvider =
    FutureProvider.family<StoreModel, String>((ref, id) {
  return _storeService.getStoreDetail(id);
});

final storeItemsProvider =
    FutureProvider.family<List<StoreItemModel>, String>((ref, id) {
  return _storeService.getStoreItems(id);
});
