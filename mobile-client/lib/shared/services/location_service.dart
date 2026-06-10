import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Returns the current permission status without requesting.
  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Requests permission and then fetches the current position.
  /// Returns null if permission is denied or location unavailable.
  Future<LocationModel?> requestAndGetLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      final city = await _cityFromPosition(position);
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _cityFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      // Try fields from most specific to least specific.
      // For Malaysia: locality = city (e.g. "Subang Jaya"),
      // subAdministrativeArea = district, administrativeArea = state.
      return p.locality?.isNotEmpty == true
          ? p.locality
          : p.subAdministrativeArea?.isNotEmpty == true
              ? p.subAdministrativeArea
              : p.administrativeArea;
    } catch (_) {
      return null;
    }
  }
}
