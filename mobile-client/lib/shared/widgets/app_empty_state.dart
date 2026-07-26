import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'custom_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Color iconBackgroundColor;
  final Color iconColor;
  final AppButtonVariant buttonVariant;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.iconBackgroundColor = AppColors.tertiary,
    this.iconColor = AppColors.primary,
    this.buttonVariant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: ctaLabel!,
                onPressed: onCta,
                variant: buttonVariant,
                isFullWidth: false,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
