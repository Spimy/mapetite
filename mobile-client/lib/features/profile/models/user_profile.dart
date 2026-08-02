import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/models/current_user.dart';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? city;

  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final List<String> allergens;
  final int dailyCalorieTarget;
  final List<String> cuisinePreferences;

  final double dineInBudget;
  final double groceryBudget;
  final int alertThresholdPercent;

  final String healthGoal;
  final String activityLevel;
  final double? weightKg;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.city,
    this.isHalal = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.allergens = const [],
    this.dailyCalorieTarget = 2000,
    this.cuisinePreferences = const [],
    this.dineInBudget = 300.0,
    this.groceryBudget = 300.0,
    this.alertThresholdPercent = 80,
    this.healthGoal = 'general_health',
    this.activityLevel = 'light',
    this.weightKg,
  });

  double get monthlyBudget => dineInBudget + groceryBudget;

  /// Reverse lookup from backend snake_case values (e.g. `'middle_eastern'`)
  /// back to the display labels the UI uses (e.g. `'Middle Eastern'`), by
  /// applying the same forward transform [ProfileSetupData.toProfileJson]
  /// uses over each known option — safer than trying to un-snake-case the
  /// string directly. Unrecognized values are dropped, not crashed on.
  static List<String> _labelsFromBackendValues(
    List<dynamic> backendValues,
    List<String> knownLabels,
  ) {
    final byValue = <String, String>{
      for (final label in knownLabels)
        label.toLowerCase().replaceAll(' ', '_'): label,
    };

    return backendValues
        .map((value) => byValue[value.toString()])
        .whereType<String>()
        .toList();
  }

  factory UserProfile.fromApi({
    required CurrentUser currentUser,
    required Map<String, dynamic> profileJson,
  }) {
    return UserProfile(
      id: currentUser.id.toString(),
      username: currentUser.username,
      email: currentUser.email,
      avatarUrl: AppConfig.resolveMediaUrl(profileJson['avatar']?.toString()),
      city: profileJson['city']?.toString(),
      isHalal: profileJson['is_halal'] as bool? ?? false,
      isVegetarian: profileJson['is_vegetarian'] as bool? ?? false,
      isVegan: profileJson['is_vegan'] as bool? ?? false,
      allergens: _labelsFromBackendValues(
        profileJson['allergies'] as List<dynamic>? ?? const [],
        AppConstants.allergenOptions,
      ),
      dailyCalorieTarget:
          (profileJson['target_calories'] as num?)?.toInt() ?? 2000,
      cuisinePreferences: _labelsFromBackendValues(
        profileJson['preferred_cuisines'] as List<dynamic>? ?? const [],
        AppConstants.cuisineCategories,
      ),
      dineInBudget:
          double.tryParse(profileJson['dine_in_budget']?.toString() ?? '') ??
              300.0,
      groceryBudget:
          double.tryParse(profileJson['grocery_budget']?.toString() ?? '') ??
              300.0,
      alertThresholdPercent:
          (profileJson['spending_alert_percent'] as num?)?.toInt() ?? 80,
      healthGoal:
          profileJson['health_goal']?.toString() ?? 'general_health',
      activityLevel: profileJson['activity_level']?.toString() ?? 'light',
      weightKg: double.tryParse(
        profileJson['current_weight']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'username': username,
      'city': city,
      'target_calories': dailyCalorieTarget,
      'dine_in_budget': dineInBudget,
      'grocery_budget': groceryBudget,
      'spending_alert_percent': alertThresholdPercent,
      'health_goal': healthGoal,
      'activity_level': activityLevel,
      'current_weight': weightKg,
      'is_halal': isHalal,
      'is_vegan': isVegan,
      'is_vegetarian': isVegetarian,
      'allergies': allergens
          .map((allergen) => allergen.toLowerCase().replaceAll(' ', '_'))
          .toList(),
      'preferred_cuisines': cuisinePreferences
          .map((cuisine) => cuisine.toLowerCase().replaceAll(' ', '_'))
          .toList(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    String? city,
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    List<String>? allergens,
    int? dailyCalorieTarget,
    List<String>? cuisinePreferences,
    double? dineInBudget,
    double? groceryBudget,
    int? alertThresholdPercent,
    String? healthGoal,
    String? activityLevel,
    double? weightKg,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      isHalal: isHalal ?? this.isHalal,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      allergens: allergens ?? this.allergens,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      dineInBudget: dineInBudget ?? this.dineInBudget,
      groceryBudget: groceryBudget ?? this.groceryBudget,
      alertThresholdPercent:
          alertThresholdPercent ?? this.alertThresholdPercent,
      healthGoal: healthGoal ?? this.healthGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
