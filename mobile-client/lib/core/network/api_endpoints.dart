abstract class ApiEndpoints {
  // Auth
  static const String register = 'auth/register/';
  static const String login = 'token/';
  static const String refreshToken = 'token/refresh/';
  static const String verifyToken = 'token/verify/';
  static const String me = 'me/';
  static const String googleLogin = 'auth/google/';
  static const String verifyEmail = 'auth/verify-email/';
  static const String resendEmail = 'auth/resend-email/';

  // Profile
  static const String profile = 'profiles/me/';

  // Discovery
  static const String discover = 'discovery/';

  // Restaurants
  static const String restaurants = 'restaurants/';
  static String restaurant(String id) => 'restaurants/$id/';

  // Groceries
  static const String groceries = 'groceries/';
  static String grocery(String id) => 'groceries/$id/';

  // Recipes
  static const String recipes = 'recipes/';
  static String recipe(String id) => 'recipes/$id/';

  // Grocery list
  static const String groceryList = 'grocery-list/';

  // Budget
  static const String budget = 'budget/';

  // Notifications
  static const String notifications = 'notifications/';

  // Routing
  static const String routing = 'routing/';
}