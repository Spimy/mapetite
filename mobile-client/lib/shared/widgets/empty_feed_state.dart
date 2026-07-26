import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_empty_state.dart';
import 'custom_button.dart';

class EmptyFeedState extends StatelessWidget {
  final String ctaLabel;
  final VoidCallback onCta;

  const EmptyFeedState({
    super.key,
    this.ctaLabel = 'Try Again',
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.location_on_outlined,
      iconBackgroundColor: AppColors.primaryLight,
      iconColor: AppColors.primary,
      title: 'Nothing nearby.',
      description: "We couldn't find anything in your area right now.",
      ctaLabel: ctaLabel,
      buttonVariant: AppButtonVariant.outlined,
      onCta: onCta,
    );
  }
}
