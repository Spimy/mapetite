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
        options: Options(
            headers: {'User-Agent': 'Mapetite/1.0 (university project)'}),
      );
      if (response.statusCode != 200 || response.data == null) return null;
      final address = response.data!['address'] as Map<String, dynamic>?;
      if (address == null) return null;

      // For Malaysian addresses Nominatim puts the municipal council name
      // (e.g. "Subang Jaya City Council") in the `city` field.
      // Prefer suburb → town → city_district → cleaned city → state.
      final raw = _str(address, 'suburb') ??
          _str(address, 'town') ??
          _str(address, 'city_district') ??
          _cleanCouncilName(_str(address, 'city')) ??
          _str(address, 'state');
      return raw;
    } catch (_) {
      return null;
    }
  }

  String? _str(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is String && v.isNotEmpty) return v;
    return null;
  }

  // Strips Malaysian administrative suffixes so "Subang Jaya City Council"
  // becomes "Subang Jaya".
  String? _cleanCouncilName(String? name) {
    if (name == null) return null;
    const suffixes = [
      ' City Council',
      ' Municipal Council',
      ' District Council',
      ' Town Council',
      ' Majlis Bandaraya',
      ' Majlis Perbandaran',
      ' Majlis Daerah',
    ];
    for (final suffix in suffixes) {
      if (name.endsWith(suffix)) {
        return name.substring(0, name.length - suffix.length).trim();
      }
    }
    return name;
  }
}
