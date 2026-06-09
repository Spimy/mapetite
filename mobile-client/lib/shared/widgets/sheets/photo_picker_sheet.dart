import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

void showPhotoPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) => const _PhotoPickerSheet(),
  );
}

class _PhotoPickerSheet extends StatelessWidget {
  const _PhotoPickerSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Change Photo', style: AppTypography.headline2),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.neutral400),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border),
        _OptionRow(
          icon: Icons.camera_alt_outlined,
          label: 'Take a photo',
          onTap: () => Navigator.of(context).pop(),
        ),
        const Divider(
          color: AppColors.border,
          indent: AppSpacing.lg,
          endIndent: AppSpacing.lg,
        ),
        _OptionRow(
          icon: Icons.photo_library_outlined,
          label: 'Choose from gallery',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SafeArea(top: false, child: SizedBox()),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, size: AppSpacing.iconSm, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.neutral400,
                size: AppSpacing.iconSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
