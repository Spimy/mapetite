/// Holds wizard answers in memory during the profile setup flow.
/// Persisted to the backend when the final setup step completes.
class ProfileSetupData {
  // Step 0 — intro
  final String? fullName;
  final String? email;

  // Step 1 — dietary
  final bool isHalal;
  final bool isVegetarian;
  final bool isVegan;
  final List<String> allergens;
  final int dailyCalorieTarget;
  final List<String> cuisinePreferences;

  // Step 2 — budget
  final double monthlyBudget;
  final double diningBudget;
  final double groceriesBudget;
  final double deliveryBudget;
  final int alertThresholdPercent;

  // Step 3 — health goals
  final String healthGoal;
  final String activityLevel;
  final double? weightKg;

  const ProfileSetupData({
    this.fullName,
    this.email,
    this.isHalal = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.allergens = const [],
    this.dailyCalorieTarget = 2000,
    this.cuisinePreferences = const [],
    this.monthlyBudget = 600.0,
    this.diningBudget = 300.0,
    this.groceriesBudget = 200.0,
    this.deliveryBudget = 100.0,
    this.alertThresholdPercent = 80,
    this.healthGoal = 'general_health',
    this.activityLevel = 'light',
    this.weightKg,
  });

  ProfileSetupData copyWith({
    String? fullName,
    String? email,
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    List<String>? allergens,
    int? dailyCalorieTarget,
    List<String>? cuisinePreferences,
    double? monthlyBudget,
    double? diningBudget,
    double? groceriesBudget,
    double? deliveryBudget,
    int? alertThresholdPercent,
    String? healthGoal,
    String? activityLevel,
    double? weightKg,
  }) {
    return ProfileSetupData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isHalal: isHalal ?? this.isHalal,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      allergens: allergens ?? this.allergens,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      diningBudget: diningBudget ?? this.diningBudget,
      groceriesBudget: groceriesBudget ?? this.groceriesBudget,
      deliveryBudget: deliveryBudget ?? this.deliveryBudget,
      alertThresholdPercent:
          alertThresholdPercent ?? this.alertThresholdPercent,
      healthGoal: healthGoal ?? this.healthGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'onboarding_completed': true,
      'target_calories': dailyCalorieTarget,
      'monthly_budget': monthlyBudget,
      'dine_in_budget': diningBudget,
      'grocery_budget': groceriesBudget,
      'delivery_budget': deliveryBudget,
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
      'cuisine_preferences': cuisinePreferences
          .map((cuisine) => cuisine.toLowerCase().replaceAll(' ', '_'))
          .toList(),
    };
  }
}