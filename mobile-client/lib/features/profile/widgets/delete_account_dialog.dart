import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeleteAccountDialog(),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final isMatch = _controller.text == 'DELETE';
      if (isMatch != _confirmed) setState(() => _confirmed = isMatch);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, size: 28, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Delete your account?',
              style: AppTypography.headline2.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This permanently deletes your account, all transaction history, and preferences. This cannot be undone.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type DELETE to confirm',
                style: AppTypography.body2.copyWith(color: AppColors.neutral600),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              style: AppTypography.body1,
              decoration: InputDecoration(
                labelText: 'Type DELETE',
                labelStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Delete Account',
              variant: AppButtonVariant.primary,
              onPressed: _confirmed ? () => Navigator.of(context).pop() : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
