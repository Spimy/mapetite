class GroceryStore {
  final String id;
  final String name;
  final String type;
  final String distance;
  final double latitude;
  final double longitude;

  const GroceryStore({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });
}

abstract class GroceryMocks {
  static const List<GroceryStore> stores = [
    GroceryStore(
      id: 'g1',
      name: 'Jaya Grocer',
      type: 'Supermarket',
      distance: '0.5 km',
      latitude: 3.0726,
      longitude: 101.6063,
    ),
    GroceryStore(
      id: 'g2',
      name: '99 Speedmart',
      type: 'Convenience',
      distance: '0.3 km',
      latitude: 3.0736,
      longitude: 101.6043,
    ),
  ];
}

class GroceryService {
  Future<List<GroceryStore>> getNearbyStores() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return GroceryMocks.stores;
    // TODO: Replace with real API call to GET /api/v1/grocery-stores/nearby
  }

  Future<GroceryStore?> getStoreById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return GroceryMocks.stores.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
    // TODO: Replace with real API call to GET /api/v1/grocery-stores/:id
  }
}
