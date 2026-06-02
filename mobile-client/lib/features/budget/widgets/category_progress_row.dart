import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class CategoryProgressRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final double spent;
  final double budget;
  final Color progressColor;
  final VoidCallback? onTap;
  final bool showDivider;

  const CategoryProgressRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.spent,
    required this.budget,
    required this.progressColor,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(icon, size: AppSpacing.iconSm, color: iconColor),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(label,
                          style: AppTypography.body1
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RM ${spent.toStringAsFixed(0)}',
                          style: AppTypography.headline3
                              .copyWith(color: AppColors.primary),
                        ),
                        Text(
                          'of RM ${budget.toStringAsFixed(0)}',
                          style: AppTypography.body2,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.chevron_right,
                        size: AppSpacing.iconSm, color: AppColors.neutral400),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.neutral200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1, color: AppColors.border,
              indent: AppSpacing.lg, endIndent: AppSpacing.lg),
      ],
    );
  }
}
