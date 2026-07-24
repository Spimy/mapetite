import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_setup_data.dart';
import '../services/profile_setup_service.dart';

class ProfileSetupController extends StateNotifier<ProfileSetupData> {
  final ProfileSetupService _profileSetupService;

  ProfileSetupController(this._profileSetupService)
      : super(const ProfileSetupData());

  void updateIntroFields({String? fullName, String? email}) {
    state = state.copyWith(fullName: fullName, email: email);
  }

  void updateDietary({
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    List<String>? allergens,
    int? dailyCalorieTarget,
    List<String>? cuisinePreferences,
  }) {
    state = state.copyWith(
      isHalal: isHalal ?? state.isHalal,
      isVegetarian: isVegetarian ?? state.isVegetarian,
      isVegan: isVegan ?? state.isVegan,
      allergens: allergens ?? state.allergens,
      dailyCalorieTarget: dailyCalorieTarget ?? state.dailyCalorieTarget,
      cuisinePreferences: cuisinePreferences ?? state.cuisinePreferences,
    );
  }

  void updateBudget({
    double? monthly,
    double? dining,
    double? groceries,
    double? delivery,
    int? alertThreshold,
  }) {
    state = state.copyWith(
      monthlyBudget: monthly ?? state.monthlyBudget,
      diningBudget: dining ?? state.diningBudget,
      groceriesBudget: groceries ?? state.groceriesBudget,
      deliveryBudget: delivery ?? state.deliveryBudget,
      alertThresholdPercent: alertThreshold ?? state.alertThresholdPercent,
    );
  }

  void updateHealthGoals({
    String? healthGoal,
    String? activityLevel,
    double? weightKg,
  }) {
    state = state.copyWith(
      healthGoal: healthGoal ?? state.healthGoal,
      activityLevel: activityLevel ?? state.activityLevel,
      weightKg: weightKg ?? state.weightKg,
    );
  }

  void toggleAllergen(String allergen) {
    final updated = List<String>.from(state.allergens);

    if (updated.contains(allergen)) {
      updated.remove(allergen);
    } else {
      updated.add(allergen);
    }

    state = state.copyWith(allergens: List.unmodifiable(updated));
  }

  void toggleCuisine(String cuisine) {
    final updated = List<String>.from(state.cuisinePreferences);

    if (updated.contains(cuisine)) {
      updated.remove(cuisine);
    } else {
      updated.add(cuisine);
    }

    state = state.copyWith(cuisinePreferences: List.unmodifiable(updated));
  }

  Future<void> submitSetup() async {
    await _profileSetupService.saveProfileSetup(state);
  }
}

final profileSetupServiceProvider = Provider<ProfileSetupService>((ref) {
  return ProfileSetupService();
});

final profileSetupControllerProvider =
    StateNotifierProvider<ProfileSetupController, ProfileSetupData>(
  (ref) => ProfileSetupController(ref.read(profileSetupServiceProvider)),
);