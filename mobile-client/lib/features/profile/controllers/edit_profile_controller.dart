import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/mocks/profile_mocks.dart';
import 'profile_setup_controller.dart';

class EditProfileController extends StateNotifier<UserProfile> {
  EditProfileController(super.initial);

  void updateDisplayName(String name) =>
      state = state.copyWith(displayName: name);

  void updateCity(String city) => state = state.copyWith(city: city);

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

  void updateBudget({double? dineIn, double? grocery, int? alertThreshold}) {
    state = state.copyWith(
      dineInBudget: dineIn ?? state.dineInBudget,
      groceryBudget: grocery ?? state.groceryBudget,
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

  Future<bool> saveChanges() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}

final editProfileControllerProvider =
    StateNotifierProvider<EditProfileController, UserProfile>((ref) {
  final setup = ref.read(profileSetupControllerProvider);
  final base = ProfileMocks.currentUser;
  return EditProfileController(UserProfile(
    id: base.id,
    displayName: setup.fullName ?? base.displayName,
    email: setup.email ?? base.email,
    phone: base.phone,
    avatarUrl: base.avatarUrl,
    city: base.city,
    isHalal: setup.isHalal,
    isVegetarian: setup.isVegetarian,
    isVegan: setup.isVegan,
    allergens: List<String>.from(setup.allergens),
    dailyCalorieTarget: setup.dailyCalorieTarget,
    cuisinePreferences: List<String>.from(setup.cuisinePreferences),
    dineInBudget: setup.dineInBudget,
    groceryBudget: setup.groceryBudget,
    alertThresholdPercent: setup.alertThresholdPercent,
    healthGoal: setup.healthGoal,
    activityLevel: setup.activityLevel,
    weightKg: setup.weightKg,
  ));
});
