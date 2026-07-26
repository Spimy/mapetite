import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_empty_state.dart';
import 'custom_button.dart';

class NetworkErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.wifi_off,
      iconBackgroundColor: AppColors.neutral100,
      iconColor: AppColors.neutral600,
      title: 'Could not connect.',
      description: 'Check your internet connection and try again.',
      ctaLabel: 'Retry',
      buttonVariant: AppButtonVariant.outlined,
      onCta: onRetry,
    );
  }
}
