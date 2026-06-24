import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationNotifier extends AsyncNotifier<LocationModel?> {
  @override
  Future<LocationModel?> build() async {
    final permission = await LocationService.instance.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return LocationService.instance.requestAndGetLocation();
    }
    return null;
  }

  Future<void> requestLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => LocationService.instance.requestAndGetLocation(),
    );
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, LocationModel?>(
  LocationNotifier.new,
);

/// Convenience provider returning the city name for display.
/// - Loading → "Locating..."
/// - Permission denied / no position → "Nearby"
/// - Position obtained but geocoding failed (e.g. web) → "Your Location"
/// - City resolved → city name
final locationCityProvider = Provider<String>((ref) {
  final location = ref.watch(locationProvider);
  return location.when(
    data: (loc) {
      if (loc == null) return 'Nearby';
      return loc.city ?? 'Your Location';
    },
    loading: () => 'Locating...',
    error: (_, _) => 'Nearby',
  );
});
