/// Mirrors StoreItemSerializer. Used for both restaurant menu items and
/// grocery products — the backend models both as StoreItem.
class StoreItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? unitSize;
  final String? thumbnailUrl;
  final String stockStatus;
  final String category;
  final List<String> dietaryTags;
  final List<String> restrictions;

  const StoreItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.unitSize,
    this.thumbnailUrl,
    required this.stockStatus,
    required this.category,
    this.dietaryTags = const [],
    this.restrictions = const [],
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    final dietaryTags = <String>[];
    if (json['vegetarian'] == true) dietaryTags.add('Vegetarian');
    if (json['organic'] == true) dietaryTags.add('Organic');
    if (json['gluten_free'] == true) dietaryTags.add('Gluten Free');
    if (json['dairy_free'] == true) dietaryTags.add('Dairy Free');

    // Restrictions = allergens present in the item.
    final restrictions = <String>[];
    if (json['contains_nuts'] == true) restrictions.add('Nuts');
    if (json['gluten_free'] == false) restrictions.add('Gluten');
    if (json['dairy_free'] == false) restrictions.add('Dairy');

    return StoreItemModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      unitSize: json['unit_size'] as String?,
      thumbnailUrl: json['thumbnail'] as String?,
      stockStatus: json['stock_status'] as String? ?? 'IN_STOCK',
      category: (json['category'] as String?) ?? 'Uncategorised',
      dietaryTags: dietaryTags,
      restrictions: restrictions,
    );
  }
}
