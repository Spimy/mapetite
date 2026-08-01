import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

/// Extracted as a top-level pure function so it's unit-testable without
/// making a real HTTP call. Priority: city (clean, recognizable) → district
/// → county → state — city is preferred over district because district-level
/// names can be as overly-specific as the bug this fix addresses (e.g.
/// "UEP Subang Jaya" instead of "Subang Jaya").
String? cityFromPhotonProperties(Map<String, dynamic> properties) {
  final raw = _str(properties, 'city') ??
      _str(properties, 'district') ??
      _str(properties, 'county') ??
      _str(properties, 'state');
  return _cleanCouncilName(raw);
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
    final photon = await _cityFromPhoton(position);
    if (photon != null) return photon;
    // Native geocoder as a last resort if the Photon HTTP call itself fails
    // (offline/timeout) — its result gets the same cleanup applied.
    return _cleanCouncilName(await _cityFromNativeGeocoder(position));
  }

  Future<String?> _cityFromPhoton(Position position) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lon': position.longitude.toString(),
          'lat': position.latitude.toString(),
        },
        options: Options(
            headers: {'User-Agent': 'Mapetite/1.0 (university project)'}),
      );
      if (response.statusCode != 200 || response.data == null) return null;
      final features = response.data!['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;
      final properties =
          (features.first as Map<String, dynamic>)['properties']
              as Map<String, dynamic>?;
      if (properties == null) return null;
      return cityFromPhotonProperties(properties);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _cityFromNativeGeocoder(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
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
}
