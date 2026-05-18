import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant { primary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? AppColors.white
                  : AppColors.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: AppSpacing.iconSm),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: variant == AppButtonVariant.primary
                      ? AppColors.white
                      : AppColors.primary,
                ),
              ),
            ],
          );

    final size = Size(
      width ?? (isFullWidth ? double.infinity : 0),
      AppSpacing.buttonHeight,
    );

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          style: ElevatedButton.styleFrom(minimumSize: size),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          style: OutlinedButton.styleFrom(minimumSize: size),
          child: child,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(minimumSize: size),
          child: child,
        );
    }
  }
}
