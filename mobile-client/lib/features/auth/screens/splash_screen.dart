import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final hasActiveSession = await ref
        .read(authControllerProvider.notifier)
        .loadCurrentUser();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);

    if (!hasActiveSession) {
      context.go(
        authState.sessionExpired ? AppRoutes.login : AppRoutes.onboarding,
      );
      return;
    }

    if (authState.onboardingCompleted) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.profileDietary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/logos/logo_wording.svg',
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Eat Smart. Live Well.',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.huge),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}