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

  // Other feature endpoints
  static const String profile = 'profiles/me/';
  static const String discover = 'discovery/';
  static const String recipes = 'recipes/';
  static String recipe(String id) => 'recipes/$id/';
  static const String groceryList = 'grocery-list/';
  static const String budget = 'budget/';
  static const String notifications = 'notifications/';
  static const String routing = 'routing/';
}