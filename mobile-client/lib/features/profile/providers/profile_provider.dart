import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/profile_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/user_profile.dart';

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  final ProfileService _profileService = ProfileService();

  @override
  Future<UserProfile> build() async {
    final currentUser = ref.read(authControllerProvider).currentUser;
    if (currentUser == null) {
      throw StateError('ProfileNotifier requires a signed-in user.');
    }

    final profileJson = await _profileService.getProfile();

    return UserProfile.fromApi(
      currentUser: currentUser,
      profileJson: profileJson,
    );
  }

  void updateUsername(String username) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(username: username));
  }

  void updateCity(String city) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(city: city));
  }

  void updateDietary({
    bool? isHalal,
    bool? isVegetarian,
    bool? isVegan,
    List<String>? allergens,
    int? dailyCalorieTarget,
    List<String>? cuisinePreferences,
  }) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      isHalal: isHalal,
      isVegetarian: isVegetarian,
      isVegan: isVegan,
      allergens: allergens,
      dailyCalorieTarget: dailyCalorieTarget,
      cuisinePreferences: cuisinePreferences,
    ));
  }

  void updateBudget({
    double? dineIn,
    double? grocery,
    int? alertThreshold,
  }) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      dineInBudget: dineIn,
      groceryBudget: grocery,
      alertThresholdPercent: alertThreshold,
    ));
  }

  void updateHealthGoals({
    String? healthGoal,
    String? activityLevel,
    double? weightKg,
  }) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      healthGoal: healthGoal,
      activityLevel: activityLevel,
      weightKg: weightKg,
    ));
  }

  /// PATCHes the currently staged profile in one call, then refreshes
  /// [authControllerProvider] so the drawer picks up a changed username
  /// immediately. Deliberately does not roll back local state on failure —
  /// unlike an instant optimistic mutation, this is a staged, explicit-save
  /// form; reverting would discard the user's edits out from under them
  /// right as they need to retry.
  Future<void> saveChanges() async {
    final current = state.requireValue;
    await _profileService.updateProfile(current.toUpdatePayload());
    await ref.read(authControllerProvider.notifier).loadCurrentUser();
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);
