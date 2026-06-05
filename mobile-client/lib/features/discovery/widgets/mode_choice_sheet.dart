import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';

void showModeChoiceSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _ModeChoiceSheet(parentContext: context),
  );
}

class _ModeChoiceSheet extends StatelessWidget {
  final BuildContext parentContext;

  const _ModeChoiceSheet({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Drag handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What do you want to do?', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Let Mapetite find the best option for you.',
                  style: AppTypography.body1.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Dine-In card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ModeCard(
              icon: Icons.restaurant,
              iconBg: AppColors.primaryLight,
              iconColor: AppColors.primary,
              title: 'Dine-In',
              subtitle: 'Find a restaurant near you',
              borderColor: AppColors.primary,
              borderWidth: 2,
              onTap: () {
                Navigator.of(context).pop();
                parentContext.go(AppRoutes.dineIn);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Cook-In card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ModeCard(
              icon: Icons.soup_kitchen,
              iconBg: AppColors.secondaryLight,
              iconColor: AppColors.secondary,
              title: 'Cook-In',
              subtitle: 'Pick a recipe and find ingredients',
              borderColor: AppColors.border,
              borderWidth: 1,
              onTap: () {
                Navigator.of(context).pop();
                parentContext.go(AppRoutes.cookIn);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.borderWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.headline2),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}
