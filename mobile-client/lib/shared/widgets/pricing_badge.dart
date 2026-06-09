import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';

enum PricingBracket { budget, mid, premium }

class PricingBadge extends StatelessWidget {
  final PricingBracket bracket;
  final String? customLabel;

  const PricingBadge({super.key, required this.bracket, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, defaultLabel) = switch (bracket) {
      PricingBracket.budget => (
          AppColors.primaryLight,
          AppColors.primary,
          'RM 5–10',
        ),
      PricingBracket.mid => (
          AppColors.secondaryLight,
          AppColors.secondary,
          'RM 10–20',
        ),
      PricingBracket.premium => (
          AppColors.warningLight,
          const Color(0xFF92400E),
          'RM 20+',
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        customLabel ?? defaultLabel,
        style: AppTypography.label.copyWith(color: fg),
      ),
    );
  }
}
