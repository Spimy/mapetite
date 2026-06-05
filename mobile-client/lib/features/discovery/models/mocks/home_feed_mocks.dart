import '../home_feed_models.dart';

abstract class HomeFeedMocks {
  static const String userName = 'Aisha';
  static const String userLocation = 'Sunway, Subang Jaya';
  static const int notificationCount = 2;

  // Top pick — used in "Today's Top Pick" featured card
  static const RestaurantSummary topPick = RestaurantSummary(
    id: 'r-top',
    name: 'Green Bowl Cafe',
    cuisine: 'Healthy Bowls',
    distanceKm: 1.2,
    rating: 4.8,
    reviewCount: 214,
    isOpen: true,
    isHalal: true,
    isVegan: false,
    isClaimed: true,
    walkMinutes: 15,
    imageUrl: null,
    matchScore: 97,
  );

  // Cook-In row — 2 recipe cards in horizontal scroll
  static const List<RecipeSummary> cookInRecipes = [
    RecipeSummary(
      id: 'rc1',
      name: 'Nasi Goreng Kampung',
      cuisine: 'Malaysian',
      prepMinutes: 30,
      calories: 450,
      isHalal: true,
      isVegan: false,
      authorName: 'Chef Hafiz',
    ),
    RecipeSummary(
      id: 'rc2',
      name: 'Mee Goreng Mamak',
      cuisine: 'Malaysian',
      prepMinutes: 25,
      calories: 520,
      isHalal: true,
      isVegan: true,
      authorName: 'Ramesh K.',
    ),
  ];

  // Nearby Options — 2 compact rows
  static const List<RestaurantSummary> nearbyRestaurants = [
    RestaurantSummary(
      id: 'r1',
      name: 'Urban Eatery',
      cuisine: 'Local Cuisine',
      distanceKm: 0.8,
      rating: 4.5,
      reviewCount: 96,
      isOpen: true,
      isHalal: true,
      isVegan: false,
      isClaimed: true,
      walkMinutes: 10,
      imageUrl: null,
      matchScore: 89,
    ),
    RestaurantSummary(
      id: 'r2',
      name: 'Fresh Daily Salad',
      cuisine: 'Healthy',
      distanceKm: 1.5,
      rating: 4.9,
      reviewCount: 61,
      isOpen: true,
      isHalal: false,
      isVegan: true,
      isClaimed: false,
      walkMinutes: 18,
      imageUrl: null,
      matchScore: 82,
    ),
  ];

  // Kept for compatibility — not shown on home screen in Phase 1
  static const List<GrocerySummary> nearbyGroceries = [
    GrocerySummary(
      id: 'g1',
      name: 'Jaya Grocer Sunway Pyramid',
      type: 'Supermarket',
      distanceKm: 0.6,
      isOpen: true,
      isClaimed: true,
    ),
    GrocerySummary(
      id: 'g2',
      name: '99 Speedmart',
      type: 'Convenience',
      distanceKm: 0.2,
      isOpen: true,
      isClaimed: false,
      closingTime: '11pm',
    ),
  ];

  static const BudgetStatus currentBudget = BudgetStatus(
    monthlyLimit: 600,
    spent: 234,
    month: 'June 2026',
  );
}
