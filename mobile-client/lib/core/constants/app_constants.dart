abstract class AppConstants {
  static const String appName = 'Mapetite';
  static const String appVersion = '1.0.0';

  // Search
  static const double defaultSearchRadiusKm = 5.0;
  static const double geofenceRadiusMeters = 100.0;
  static const double maxSearchRadiusKm = 20.0;

  // Budget
  static const double defaultBudgetWarningPct = 0.80;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation durations (milliseconds)
  static const int animFast = 150;
  static const int animNormal = 300;
  static const int animSlow = 500;

  // Image cache
  static const int imageCacheDurationHours = 24;

  // Cuisine categories
  static const List<String> cuisineCategories = [
    'Malaysian', 'Chinese', 'Indian', 'Japanese',
    'Western', 'Thai', 'Korean', 'Middle Eastern',
  ];

  // Dietary options
  static const List<String> dietaryOptions = [
    'Halal', 'Vegetarian', 'Vegan',
  ];

  // Allergen options
  static const List<String> allergenOptions = [
    'Nuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Soy',
  ];
}
