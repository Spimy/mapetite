import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../custom_button.dart';

void showSessionExpiredDialog() {
  final context = appNavigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SessionExpiredDialog(),
  );
}

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Session expired',
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please sign in again to continue.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Sign In',
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
