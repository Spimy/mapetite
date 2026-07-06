abstract class ApiEndpoints {
  // Auth
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/token/refresh/';

  // Profile
  static const String profile = '/profiles/me/';

  // Discovery
  static const String discover = '/discovery/';

  // Restaurants (maps to server's /api/stores/ endpoints, filtered by type)
  static const String restaurants = '/api/stores/?type=RESTAURANT';
  static String restaurant(String id) => '/api/stores/$id/';

  // Groceries (maps to server's /api/stores/ endpoints, filtered by type)
  static const String groceries = '/api/stores/?type=GROCERY';
  static String grocery(String id) => '/api/stores/$id/';

  // Recipes
  static const String recipes = '/recipes/';
  static String recipe(String id) => '/recipes/$id/';

  // Grocery list
  static const String groceryList = '/grocery-list/';

  // Budget
  static const String budget = '/budget/';

  // Notifications
  static const String notifications = '/notifications/';

  // Routing
  static const String routing = '/routing/';
}
