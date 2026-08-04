import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/restaurant_recommendation_model.dart';

Future<void> showRestaurantRecommendationSheet(
  BuildContext context, {
  required RestaurantRecommendation recommendation,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RestaurantRecommendationSheet(
      recommendation: recommendation,
      onAccept: onAccept,
      onReject: onReject,
    ),
  );
}

class RestaurantRecommendationSheet extends StatelessWidget {
  final RestaurantRecommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RestaurantRecommendationSheet({
    super.key,
    required this.recommendation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final store = recommendation.store;
    final distanceKm = recommendation.distanceKm ?? store.distanceKm;
    final reason = recommendation.recommendationReason?.trim();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommended for you', style: AppTypography.headline3),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        recommendation.matchPercentText,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(store.businessName, style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              store.streetAddress.isEmpty
                  ? 'Nearby restaurant'
                  : store.streetAddress,
              style: AppTypography.body2.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (distanceKm != null)
                  _InfoChip(
                    icon: Icons.directions_walk,
                    label: '${distanceKm.toStringAsFixed(1)} km',
                  ),
                if (recommendation.isOpen != null)
                  _InfoChip(
                    icon: recommendation.isOpen!
                        ? Icons.schedule
                        : Icons.schedule_outlined,
                    label: recommendation.isOpen! ? 'Open now' : 'Closed',
                  ),
                if (recommendation.pricingBracket != null &&
                    recommendation.pricingBracket!.trim().isNotEmpty)
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: recommendation.pricingBracket!,
                  ),
                ...store.dietaryTags.map(
                  (tag) => _InfoChip(icon: Icons.verified_outlined, label: tag),
                ),
              ],
            ),
            if (reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                reason,
                style: AppTypography.body1.copyWith(color: AppColors.neutral700),
              ),
            ] else if (recommendation.reasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...recommendation.reasons.take(3).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              item,
                              style: AppTypography.body2.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Accept and Navigate',
              leadingIcon: Icons.navigation_outlined,
              onPressed: () {
                Navigator.of(context).pop();
                onAccept();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Browse instead',
              variant: AppButtonVariant.ghost,
              onPressed: () {
                Navigator.of(context).pop();
                onReject();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral600),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.label.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}