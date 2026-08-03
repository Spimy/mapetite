import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

void showPhotoPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) => const _PhotoPickerSheet(),
  );
}

class _PhotoPickerSheet extends ConsumerStatefulWidget {
  const _PhotoPickerSheet();

  @override
  ConsumerState<_PhotoPickerSheet> createState() => _PhotoPickerSheetState();
}

class _PhotoPickerSheetState extends ConsumerState<_PhotoPickerSheet> {
  bool _isUploading = false;

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await picked.readAsBytes();
      await ref.read(profileProvider.notifier).uploadAvatar(bytes, picked.name);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to upload photo. Please try again.',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

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
                onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.neutral400),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border),
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          )
        else ...[
          _OptionRow(
            icon: Icons.camera_alt_outlined,
            label: 'Take a photo',
            onTap: () => _pickAndUpload(ImageSource.camera),
          ),
          const Divider(color: AppColors.border, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          _OptionRow(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => _pickAndUpload(ImageSource.gallery),
          ),
        ],
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
                child: Text(label, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.neutral400, size: AppSpacing.iconSm),
            ],
          ),
        ),
      ),
    );
  }
}
