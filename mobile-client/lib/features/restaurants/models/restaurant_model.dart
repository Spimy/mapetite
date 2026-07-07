import '../../../shared/widgets/pricing_badge.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> dietaryTags;
  final List<String> restrictions;
  final String category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.dietaryTags = const [],
    this.restrictions = const [],
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final dietaryTags = <String>[];
    if (json['vegetarian'] == true) dietaryTags.add('Vegetarian');
    if (json['organic'] == true) dietaryTags.add('Organic');
    if (json['gluten_free'] == true) dietaryTags.add('Gluten Free');
    if (json['dairy_free'] == true) dietaryTags.add('Dairy Free');

    // Restrictions = allergens present in the item
    final restrictions = <String>[];
    if (json['contains_nuts'] == true) restrictions.add('Nuts');
    if (json['gluten_free'] == false) restrictions.add('Gluten');
    if (json['dairy_free'] == false) restrictions.add('Dairy');

    final thumbnail = json['thumbnail'] as String?;

    return MenuItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: (thumbnail != null && thumbnail.isNotEmpty) ? thumbnail : null,
      dietaryTags: dietaryTags,
      restrictions: restrictions,
      category: (json['category_name'] as String?) ?? 'Uncategorised',
    );
  }
}

class RestaurantModel {
  final String id;
  final String name;
  final String cuisineType;
  final double distanceKm;
  final int walkMinutes;
  final List<String> dietaryTags;
  final PricingBracket pricingBracket;
  final String recommendationReason;
  final String? imageUrl;
  final String address;
  final String phone;
  final bool isOpen;
  final String closingTime;
  final double lat;
  final double lng;
  final List<MenuItem> menuItems;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisineType,
    required this.distanceKm,
    required this.walkMinutes,
    this.dietaryTags = const [],
    required this.pricingBracket,
    required this.recommendationReason,
    this.imageUrl,
    required this.address,
    required this.phone,
    this.isOpen = true,
    required this.closingTime,
    required this.lat,
    required this.lng,
    this.menuItems = const [],
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // Derive dietary tags from store-level halal/vegan flags
    final dietaryTags = <String>[];
    if (json['halal'] == true) dietaryTags.add('Halal');
    if (json['vegan'] == true) dietaryTags.add('Vegan');

    // Determine today's open/close status from operating hours
    // Server uses 0=Monday–6=Sunday; Dart weekday is 1=Monday–7=Sunday
    final todayIndex = DateTime.now().weekday - 1;
    final hours = (json['operating_hours'] as List<dynamic>?) ?? [];
    final todayHours = hours.cast<Map<String, dynamic>>().firstWhere(
          (h) => h['day_of_week'] == todayIndex,
          orElse: () => {'is_closed': true},
        );
    final isOpen = todayHours['is_closed'] != true;
    final closingTime = isOpen ? (todayHours['close_time'] as String? ?? '') : 'Closed';

    // Parse menu items, only include active ones
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final menuItems = rawItems
        .cast<Map<String, dynamic>>()
        .where((item) => item['is_active'] != false)
        .map(MenuItem.fromJson)
        .toList();

    return RestaurantModel(
      id: json['id'].toString(),
      name: json['business_name'] as String,
      cuisineType: json['merchant_type'] as String? ?? '',
      distanceKm: 0,       // Calculated separately once location services are integrated
      walkMinutes: 0,       // Calculated separately once location services are integrated
      dietaryTags: dietaryTags,
      pricingBracket: PricingBracket.mid,   // No server field yet; default to mid
      recommendationReason: '',             // No server field yet
      address: (json['street_address'] as String?) ?? '',
      phone: '',            // No server field yet
      isOpen: isOpen,
      closingTime: closingTime,
      lat: (json['latitude'] as num?)?.toDouble() ?? 0,
      lng: (json['longitude'] as num?)?.toDouble() ?? 0,
      menuItems: menuItems,
    );
  }
}
