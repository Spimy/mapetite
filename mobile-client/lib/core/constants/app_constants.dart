import 'package:flutter/material.dart';

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

  // Cuisine categories — must match the backend's cuisine choices exactly
  // (server/apps/users/models.py UserProfile.PreferredCuisineChoices and
  // server/apps/merchants/models.py StoreProfile.Category): a label here
  // that doesn't exist on the backend causes a 400 on save (see #113).
  static const List<String> cuisineCategories = [
    'Mamak', 'Nasi Kandar', 'Malaysian', 'Kopitiam',
    'Chinese', 'Japanese', 'Korean', 'Fusion',
    'Indonesian', 'Mexican', 'Mediterranean', 'Healthy', 'Vegetarian',
  ];

  // Dietary options
  static const List<String> dietaryOptions = [
    'Halal', 'Vegetarian', 'Vegan',
  ];

  // Allergen options
  static const List<String> allergenOptions = [
    'Nuts', 'Dairy', 'Gluten', 'Shellfish', 'Eggs', 'Soy',
  ];

  // Cuisine icons
  static const Map<String, IconData> cuisineIcons = {
    'Mamak':         Icons.local_cafe,
    'Nasi Kandar':   Icons.dinner_dining,
    'Malaysian':     Icons.rice_bowl,
    'Kopitiam':      Icons.coffee,
    'Chinese':       Icons.ramen_dining,
    'Japanese':      Icons.set_meal,
    'Korean':        Icons.outdoor_grill,
    'Fusion':        Icons.auto_awesome,
    'Indonesian':    Icons.soup_kitchen,
    'Mexican':       Icons.local_fire_department,
    'Mediterranean': Icons.kebab_dining,
    'Healthy':       Icons.eco,
    'Vegetarian':    Icons.grass,
  };
}
