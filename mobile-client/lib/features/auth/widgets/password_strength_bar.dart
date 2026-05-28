import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final int strength = Validators.calculatePasswordStrength(password);
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? AppSpacing.xs : 0),
            decoration: BoxDecoration(
              color: _segmentColor(strength, i),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      }),
    );
  }

  Color _segmentColor(int strength, int index) {
    if (strength == 0 || index >= strength) return AppColors.border;
    switch (strength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.secondary;
      case 4:
        return AppColors.success;
      default:
        return AppColors.border;
    }
  }
}
