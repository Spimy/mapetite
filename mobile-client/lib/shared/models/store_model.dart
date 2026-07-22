import '../../core/utils/opening_hours_util.dart';

enum StoreType {
  restaurant,
  grocery;

  String get apiValue => switch (this) {
        StoreType.restaurant => 'RESTAURANT',
        StoreType.grocery => 'GROCERY',
      };

  static StoreType fromApiValue(String value) => switch (value) {
        'RESTAURANT' => StoreType.restaurant,
        'GROCERY' => StoreType.grocery,
        _ => throw ArgumentError('Unknown merchant_type: $value'),
      };
}

/// Approximate walking pace used to estimate walk time from distance.
/// ~5 km/h, i.e. 12 minutes per kilometre.
const int _walkingMinutesPerKm = 12;

/// Mirrors StoreProfileSerializer / NearbyStoreSerializer. Used for both
/// restaurants and grocery stores — the backend itself only distinguishes
/// them via [merchantType], so mobile shouldn't maintain two parallel models.
///
/// [phone] may be empty/absent for some stores; [category] is nullable
/// because the backend does not provide it yet — UI must hide the
/// corresponding chip/row when null rather than assume a value.
class StoreModel {
  final String id;
  final String businessName;
  final String description;
  final StoreType merchantType;
  final bool halal;
  final bool vegan;
  final String streetAddress;
  final String? imageUrl;
  final List<OperatingHourModel> operatingHours;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? phone;
  final String? category;

  const StoreModel({
    required this.id,
    required this.businessName,
    required this.description,
    required this.merchantType,
    required this.halal,
    required this.vegan,
    required this.streetAddress,
    this.imageUrl,
    this.operatingHours = const [],
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.phone,
    this.category,
  });

  OpenStatus get openStatus => computeOpenStatus(operatingHours, DateTime.now());

  int? get walkMinutesEstimate =>
      distanceKm == null ? null : (distanceKm! * _walkingMinutesPerKm).round();

  List<String> get dietaryTags => [
        if (halal) 'Halal',
        if (vegan) 'Vegan',
      ];

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final hoursJson = (json['operating_hours'] as List<dynamic>?) ?? [];
    return StoreModel(
      id: json['id'].toString(),
      businessName: json['business_name'] as String,
      description: (json['description'] as String?) ?? '',
      merchantType: StoreType.fromApiValue(json['merchant_type'] as String),
      halal: json['halal'] as bool? ?? false,
      vegan: json['vegan'] as bool? ?? false,
      streetAddress: (json['street_address'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      operatingHours: hoursJson
          .cast<Map<String, dynamic>>()
          .map(OperatingHourModel.fromJson)
          .toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      category: json['category'] as String?,
    );
  }
}
