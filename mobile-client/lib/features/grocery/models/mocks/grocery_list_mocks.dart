import '../grocery_list_model.dart';

abstract class GroceryListMocks {
  static const double weeklyBudgetLimit = 50.0;

  static final List<GroceryListItem> initialItems = [
    const GroceryListItem(
      id: 'g1',
      name: 'Organic Avocados',
      quantity: '3 pcs',
      storeName: 'Fresh Mart',
      estimatedPrice: 12.50,
    ),
    const GroceryListItem(
      id: 'g2',
      name: 'Almond Milk',
      quantity: '1 L',
      storeName: 'Dairy Co.',
      estimatedPrice: 9.90,
    ),
    const GroceryListItem(
      id: 'g3',
      name: 'Sourdough Bread',
      quantity: '1 loaf',
      storeName: 'Local Bakery',
      estimatedPrice: 8.00,
    ),
    const GroceryListItem(
      id: 'g4',
      name: 'Free-Range Eggs',
      quantity: '10 pack',
      storeName: 'Farm Fresh',
      estimatedPrice: 7.50,
      isChecked: true,
    ),
    const GroceryListItem(
      id: 'g5',
      name: 'Baby Spinach',
      quantity: '200 g',
      storeName: 'Green Grocer',
      estimatedPrice: 4.50,
      isChecked: true,
    ),
  ];
}
