import '../home_feed_models.dart';

abstract class HomeFeedMocks {
  static const String userName = 'Joshua';
  static const String userLocation = 'Bangsar';
  static const double budgetRemaining = 366.0;
  static const int unreadNotifications = 2;

  static const RestaurantSummary topPick = RestaurantSummary(
    id: 'r_botanica',
    name: 'Botanica + Co',
    cuisine: 'Fresh salads & hearty bowls',
    distanceKm: 0.8,
    rating: 4.8,
    reviewCount: 142,
    isOpen: true,
    isHalal: true,
    isVegan: false,
    isClaimed: true,
    walkMinutes: 10,
    pricingBracket: 'RM 20+',
    imageUrl: null,
    matchScore: 94,
  );

  static const List<RestaurantSummary> nearbyOptions = [
    RestaurantSummary(
      id: 'r_fishbowl',
      name: 'The Fish Bowl',
      cuisine: 'Healthy · Poke',
      distanceKm: 1.2,
      rating: 4.6,
      reviewCount: 89,
      isOpen: true,
      isHalal: false,
      isVegan: false,
      isClaimed: true,
      walkMinutes: 15,
      pricingBracket: 'RM 10-20',
      imageUrl: null,
      matchScore: 87,
    ),
    RestaurantSummary(
      id: 'r_pulp',
      name: 'Pulp by PPP',
      cuisine: 'Cafe · Pastries',
      distanceKm: 0.5,
      rating: 4.7,
      reviewCount: 213,
      isOpen: true,
      isHalal: true,
      isVegan: false,
      isClaimed: true,
      walkMinutes: 6,
      pricingBracket: 'RM 10-20',
      imageUrl: null,
      matchScore: 82,
    ),
  ];

  // Legacy fields retained for backward compatibility with other screens
  static const List<RecipeSummary> cookInRecipes = [
    RecipeSummary(
      id: 'rc1',
      name: 'Nasi Goreng Kampung',
      cuisine: 'Malaysian',
      prepMinutes: 25,
      calories: 450,
      isHalal: true,
      isVegan: false,
      authorName: 'Chef Hafiz',
    ),
    RecipeSummary(
      id: 'rc2',
      name: 'Mee Goreng Mamak',
      cuisine: 'Malaysian',
      prepMinutes: 20,
      calories: 380,
      isHalal: true,
      isVegan: true,
      authorName: 'Ramesh K.',
    ),
  ];

  static const List<RestaurantSummary> nearbyRestaurants = nearbyOptions;

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
      name: '99 Speedmart',
      type: 'Convenience',
      distanceKm: 0.4,
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
