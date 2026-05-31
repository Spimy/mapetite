import '../user_profile.dart';

abstract class ProfileMocks {
  static const UserProfile currentUser = UserProfile(
    id: 'u1',
    displayName: 'Aisha Salleh',
    email: 'aisha.salleh@example.com',
    phone: '+60 12-345 6789',
    avatarUrl: null,
    city: 'Bangsar, Kuala Lumpur',
    isHalal: true,
    isVegetarian: false,
    isVegan: false,
    allergens: ['Nuts'],
    dailyCalorieTarget: 2000,
    cuisinePreferences: ['Malaysian', 'Japanese'],
    monthlyBudget: 600.0,
    alertThresholdPercent: 80,
    healthGoal: 'general_health',
    activityLevel: 'light',
  );
}
