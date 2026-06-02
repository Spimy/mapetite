import '../home_feed_models.dart';

abstract class HomeFeedMocks {
  static const String userName = 'Aisha';
  static const String userLocation = 'Bangsar';
  static const int notificationCount = 3;

  static const List<RestaurantSummary> nearbyRestaurants = [
    RestaurantSummary(
      id: 'r1',
      name: 'Nasi Kandar Pelita',
      cuisine: 'Northern Malaysian',
      distanceKm: 0.8,
      rating: 4.7,
      reviewCount: 128,
      isOpen: true,
      isHalal: true,
      isVegan: false,
      isClaimed: true,
      walkMinutes: 12,
      brtRoute: null,
      imageUrl: null,
      matchScore: 94,
    ),
    RestaurantSummary(
      id: 'r2',
      name: 'Sushi Zanmai',
      cuisine: 'Japanese',
      distanceKm: 2.1,
      rating: 4.5,
      reviewCount: 89,
      isOpen: true,
      isHalal: false,
      isVegan: true,
      isClaimed: true,
      walkMinutes: 28,
      brtRoute: 'Bangsar > KLCC',
      imageUrl: null,
      matchScore: 87,
    ),
    RestaurantSummary(
      id: 'r3',
      name: 'Kafe Old Town',
      cuisine: 'Local Malaysian',
      distanceKm: 0.5,
      rating: 4.3,
      reviewCount: 204,
      isOpen: true,
      isHalal: true,
      isVegan: false,
      isClaimed: false,
      walkMinutes: 7,
      brtRoute: null,
      imageUrl: null,
      matchScore: 82,
    ),
  ];

  static const List<GrocerySummary> nearbyGroceries = [
    GrocerySummary(
      id: 'g1',
      name: 'Jaya Grocer',
      type: 'Supermarket',
      distanceKm: 1.5,
      isOpen: true,
      isClaimed: true,
    ),
    GrocerySummary(
      id: 'g2',
      name: 'Mydin',
      type: 'Hypermarket',
      distanceKm: 2.8,
      isOpen: true,
      isClaimed: false,
      closingTime: '10pm',
    ),
  ];

  static const List<RecipeSummary> trendingRecipes = [
    RecipeSummary(
      id: 'r5',
      name: 'Mee Goreng Mamak',
      cuisine: 'Malaysian',
      prepMinutes: 25,
      calories: 490,
      isHalal: true,
      isVegan: false,
      authorName: 'Ramesh K.',
    ),
    RecipeSummary(
      id: 'r3',
      name: 'Roti John',
      cuisine: 'Malaysian',
      prepMinutes: 20,
      calories: 520,
      isHalal: true,
      isVegan: false,
      authorName: 'Hafiz M.',
    ),
  ];

  static const BudgetStatus currentBudget = BudgetStatus(
    monthlyLimit: 600,
    spent: 234,
    month: 'May 2026',
  );
}
