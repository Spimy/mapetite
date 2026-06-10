import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 6),
  ));

  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

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
    // 1. Try native geocoder (works on iOS / Android).
    final native = await _cityFromNativeGeocoder(position);
    if (native != null) return native;

    // 2. Fall back to Nominatim HTTP API (works on web + any platform).
    return _cityFromNominatim(position);
  }

  Future<String?> _cityFromNativeGeocoder(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      // locality = city name (e.g. "Subang Jaya")
      // subAdministrativeArea = district, administrativeArea = state
      return p.locality?.isNotEmpty == true
          ? p.locality
          : p.subAdministrativeArea?.isNotEmpty == true
              ? p.subAdministrativeArea
              : p.administrativeArea?.isNotEmpty == true
                  ? p.administrativeArea
                  : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _cityFromNominatim(Position position) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'Mapetite/1.0 (university project)'}),
      );
      if (response.statusCode != 200 || response.data == null) return null;
      final address = response.data!['address'] as Map<String, dynamic>?;
      if (address == null) return null;
      // Nominatim uses city / town / village / suburb in order of specificity.
      return (address['city'] as String?)?.isNotEmpty == true
          ? address['city'] as String
          : (address['town'] as String?)?.isNotEmpty == true
              ? address['town'] as String
              : (address['suburb'] as String?)?.isNotEmpty == true
                  ? address['suburb'] as String
                  : address['state'] as String?;
    } catch (_) {
      return null;
    }
  }
}
