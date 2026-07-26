import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import 'app_empty_state.dart';

class LocationDeniedState extends StatelessWidget {
  const LocationDeniedState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.location_disabled,
      iconBackgroundColor: AppColors.warningLight,
      iconColor: AppColors.warning,
      title: 'Location needed.',
      description: "Enable location access in Settings to see what's nearby.",
      ctaLabel: 'Open Settings',
      onCta: () => openAppSettings(),
    );
  }
}
