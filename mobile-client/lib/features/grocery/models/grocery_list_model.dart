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

  bool get hasLinkedStore => storeId != null && storeLatitude != null && storeLongitude != null;

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
