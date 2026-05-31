class UserProfile {
  final String id;
  final String displayName;
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

  final double monthlyBudget;
  final int alertThresholdPercent;

  final String healthGoal;
  final String activityLevel;
  final double? weightKg;

  const UserProfile({
    required this.id,
    required this.displayName,
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
    this.monthlyBudget = 600.0,
    this.alertThresholdPercent = 80,
    this.healthGoal = 'general_health',
    this.activityLevel = 'light',
    this.weightKg,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
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
    double? monthlyBudget,
    int? alertThresholdPercent,
    String? healthGoal,
    String? activityLevel,
    double? weightKg,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
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
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      alertThresholdPercent: alertThresholdPercent ?? this.alertThresholdPercent,
      healthGoal: healthGoal ?? this.healthGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
