import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../custom_button.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const LogoutDialog(),
  );
}

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                size: 28,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sign out?',
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "You'll need to sign in again to access your account.",
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Sign Out',
                    onPressed: () async {
                      final router = GoRouter.of(context);

                      Navigator.of(context).pop();

                      await ref.read(authControllerProvider.notifier).logout();

                      router.go('/login');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
