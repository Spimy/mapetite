import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/auth/models/current_user.dart' as auth;
import 'package:mapetite/features/profile/models/user_profile.dart';

auth.CurrentUser _currentUser({String username = 'jbonham', String email = 'j@example.com'}) {
  return auth.CurrentUser.fromJson({
    'id': 1,
    'email': email,
    'username': username,
    'first_name': '',
    'last_name': '',
    'is_verified': true,
    'profile': <String, dynamic>{},
  });
}

void main() {
  group('UserProfile.fromApi', () {
    test('merges identity from CurrentUser and preferences from the profile map', () {
      final profile = UserProfile.fromApi(
        currentUser: _currentUser(username: 'jbonham', email: 'j@example.com'),
        profileJson: {
          'city': 'Bangsar, Kuala Lumpur',
          'target_calories': 2200,
          'dine_in_budget': '250.00',
          'grocery_budget': '350.00',
          'spending_alert_percent': 75,
          'health_goal': 'lose_weight',
          'activity_level': 'active',
          'current_weight': '70.50',
          'is_halal': true,
          'is_vegan': false,
          'is_vegetarian': false,
          'allergies': ['nuts', 'gluten'],
          'preferred_cuisines': ['malaysian', 'nasi_kandar'],
        },
      );

      expect(profile.username, 'jbonham');
      expect(profile.email, 'j@example.com');
      expect(profile.city, 'Bangsar, Kuala Lumpur');
      expect(profile.dailyCalorieTarget, 2200);
      expect(profile.dineInBudget, 250.0);
      expect(profile.groceryBudget, 350.0);
      expect(profile.alertThresholdPercent, 75);
      expect(profile.healthGoal, 'lose_weight');
      expect(profile.activityLevel, 'active');
      expect(profile.weightKg, 70.5);
      expect(profile.isHalal, isTrue);
      expect(profile.allergens, ['Nuts', 'Gluten']);
      expect(profile.cuisinePreferences, ['Malaysian', 'Nasi Kandar']);
    });

    test('drops unrecognized allergen/cuisine values instead of crashing', () {
      final profile = UserProfile.fromApi(
        currentUser: _currentUser(),
        profileJson: {
          'allergies': ['nuts', 'some_new_allergy_backend_added'],
          'preferred_cuisines': <String>[],
        },
      );

      expect(profile.allergens, ['Nuts']);
    });
  });

  group('UserProfile.toUpdatePayload', () {
    test('produces the exact backend key names, including preferred_cuisines', () {
      const profile = UserProfile(
        id: 'u1',
        username: 'jbonham',
        email: 'j@example.com',
        city: 'Bangsar',
        isHalal: true,
        isVegetarian: false,
        isVegan: false,
        allergens: ['Nuts'],
        dailyCalorieTarget: 2000,
        cuisinePreferences: ['Malaysian', 'Nasi Kandar'],
        dineInBudget: 300.0,
        groceryBudget: 300.0,
        alertThresholdPercent: 80,
        healthGoal: 'general_health',
        activityLevel: 'light',
        weightKg: 70.0,
      );

      final payload = profile.toUpdatePayload();

      expect(payload['username'], 'jbonham');
      expect(payload['city'], 'Bangsar');
      expect(payload['target_calories'], 2000);
      expect(payload['dine_in_budget'], 300.0);
      expect(payload['grocery_budget'], 300.0);
      expect(payload['spending_alert_percent'], 80);
      expect(payload['health_goal'], 'general_health');
      expect(payload['activity_level'], 'light');
      expect(payload['current_weight'], 70.0);
      expect(payload['is_halal'], true);
      expect(payload['is_vegan'], false);
      expect(payload['is_vegetarian'], false);
      expect(payload['allergies'], ['nuts']);
      expect(payload.containsKey('cuisine_preferences'), isFalse);
      expect(payload['preferred_cuisines'], ['malaysian', 'nasi_kandar']);
    });
  });
}
