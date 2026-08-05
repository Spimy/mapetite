class GroceryListItem {
  final String id;
  final String name;
  final String quantity;
  final String storeName;
  final String? storeId;
  final double? storeLatitude;
  final double? storeLongitude;
  final double estimatedPrice;
  final bool isChecked;

  const GroceryListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.storeName,
    this.storeId,
    this.storeLatitude,
    this.storeLongitude,
    required this.estimatedPrice,
    this.isChecked = false,
  });

  factory GroceryListItem.fromJson(Map<String, dynamic> json) {
    return GroceryListItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? 'Unknown Store',
      storeId: json['storeId']?.toString(),
      storeLatitude: _doubleFromJson(json['storeLatitude']),
      storeLongitude: _doubleFromJson(json['storeLongitude']),
      estimatedPrice: _doubleFromJson(json['estimatedPrice']) ?? 0,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'storeName': storeName,
      'storeId': storeId,
      'storeLatitude': storeLatitude,
      'storeLongitude': storeLongitude,
      'estimatedPrice': estimatedPrice,
      'isChecked': isChecked,
    };
  }

  bool get hasLinkedStore =>
      storeId != null && storeLatitude != null && storeLongitude != null;

  GroceryListItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? storeName,
    String? storeId,
    double? storeLatitude,
    double? storeLongitude,
    double? estimatedPrice,
    bool? isChecked,
  }) {
    return GroceryListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      storeLatitude: storeLatitude ?? this.storeLatitude,
      storeLongitude: storeLongitude ?? this.storeLongitude,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}