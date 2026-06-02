class GroceryListItem {
  final String id;
  final String name;
  final String quantity;
  final String storeName;
  final double estimatedPrice;
  final bool isChecked;

  const GroceryListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.storeName,
    required this.estimatedPrice,
    this.isChecked = false,
  });

  GroceryListItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? storeName,
    double? estimatedPrice,
    bool? isChecked,
  }) {
    return GroceryListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      storeName: storeName ?? this.storeName,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
