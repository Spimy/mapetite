abstract class ApiEndpoints {
  // Auth
  static const String register = 'auth/register/';
  static const String googleLogin = 'auth/google/';
  static const String verifyEmail = 'auth/verify-email/';
  static const String resendEmail = 'auth/resend-email/';

  // JWT token auth
  static const String login = 'token/';
  static const String refreshToken = 'token/refresh/';
  static const String verifyToken = 'token/verify/';

  // Current user
  static const String me = 'me/';

  // Stores
  static const String restaurants = 'stores/?type=RESTAURANT';
  static String restaurant(String id) => 'stores/$id/';

  static const String groceries = 'stores/?type=GROCERY';
  static String grocery(String id) => 'stores/$id/';

  // Stores (unified — used by StoreService, shared across restaurant/grocery features)
  static const String stores = 'stores/';
  static const String storesNearby = 'stores/nearby/';
  static String storeDetail(String id) => 'stores/$id/';
  static String storeItems(String id) => 'stores/$id/items/';

  // Recommendations
  static const String restaurantRecommendations = 'recommendations/restaurants/';
  static const String recommendationTopPick = 'recommendations/top-pick/';

  // Other feature endpoints
  static const String discover = 'discovery/';
  static const String recipes = 'recipes/';
  static String recipe(String id) => 'recipes/$id/';
  static String recipeSave(String id) => 'recipes/$id/save/';
  static const String ingredientSearchNearbyStores = 'ingredients/search-nearby-stores/';
  static const String groceryList = 'grocery-list/';
  static const String budget = 'spending-records/';
  static String budgetDetail(String id) => 'spending-records/$id/';
  static const String budgetSummary = 'spending-records/summary/';
  static const String notifications = 'notifications/';
  static String notificationDetail(String id) => 'notifications/$id/';
  static const String routing = 'routing/';
}