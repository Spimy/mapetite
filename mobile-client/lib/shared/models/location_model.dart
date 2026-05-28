class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        city: json['city'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
      };
}
