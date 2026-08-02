import '../../../core/config/app_config.dart';

class CurrentUser {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final bool isVerified;
  final UserProfile profile;

  const CurrentUser({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    required this.profile,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      profile: UserProfile.fromJson(
        json['profile'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  String get displayName {
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (username.isNotEmpty) {
      return username;
    }

    return email;
  }
}

class UserProfile {
  final bool onboardingCompleted;
  final String? avatar;
  final String phoneNumber;
  final String address;
  final String city;
  final String country;
  final int spendingAlertPercent;
  final String healthGoal;
  final String activityLevel;
  final bool isHalal;
  final bool isVegan;
  final List<String> allergies;

  const UserProfile({
    required this.onboardingCompleted,
    required this.avatar,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.country,
    required this.spendingAlertPercent,
    required this.healthGoal,
    required this.activityLevel,
    required this.isHalal,
    required this.isVegan,
    required this.allergies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      avatar: AppConfig.resolveMediaUrl(json['avatar'] as String?),
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      spendingAlertPercent: json['spending_alert_percent'] as int? ?? 80,
      healthGoal: json['health_goal'] as String? ?? '',
      activityLevel: json['activity_level'] as String? ?? '',
      isHalal: json['is_halal'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      allergies: (json['allergies'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }
}