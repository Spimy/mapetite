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
}
