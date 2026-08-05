import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mapetite/features/auth/controllers/auth_controller.dart';
import 'package:mapetite/features/auth/models/auth_state.dart';
import 'package:mapetite/features/auth/models/current_user.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';
import 'package:mapetite/features/settings/screens/app_settings_screen.dart';
import 'package:mapetite/shared/providers/location_provider.dart';

const _testProfile = UserProfile(
  onboardingCompleted: true,
  avatar: null,
  phoneNumber: '',
  address: '',
  city: '',
  country: '',
  spendingAlertPercent: 80,
  healthGoal: '',
  activityLevel: '',
  isHalal: false,
  isVegan: false,
  allergies: [],
);

const _testProfileWithAvatar = UserProfile(
  onboardingCompleted: true,
  avatar: 'http://localhost:8000/media/users/avatars/x.jpg',
  phoneNumber: '',
  address: '',
  city: '',
  country: '',
  spendingAlertPercent: 80,
  healthGoal: '',
  activityLevel: '',
  isHalal: false,
  isVegan: false,
  allergies: [],
);

const _testUser = CurrentUser(
  id: 1,
  email: 'joshua@example.com',
  username: 'joshua',
  firstName: 'Joshua',
  lastName: '',
  isVerified: true,
  profile: _testProfile,
);

const _testUserWithAvatar = CurrentUser(
  id: 1,
  email: 'joshua@example.com',
  username: 'joshua',
  firstName: 'Joshua',
  lastName: '',
  isVerified: true,
  profile: _testProfileWithAvatar,
);

Widget _wrap({required CurrentUser currentUser}) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(
      (ref) => AuthController(AuthService())
        ..state = AuthState(currentUser: currentUser),
    ),
    locationPermissionStatusProvider.overrideWith(
      (ref) async => LocationPermission.denied,
    ),
  ],
  child: const MaterialApp(home: AppSettingsScreen()),
);

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Mapetite',
      packageName: 'com.mapetite.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('AppSettingsScreen — profile avatar', () {
    testWidgets('renders initials when the user has no avatar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(currentUser: _testUser));
      await tester.pumpAndSettle();

      expect(find.text('J'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('renders a CachedNetworkImage for the user\'s avatar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(currentUser: _testUserWithAvatar));
      await tester.pumpAndSettle();

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(
        image.imageUrl,
        'http://localhost:8000/media/users/avatars/x.jpg',
      );
    });
  });
}
