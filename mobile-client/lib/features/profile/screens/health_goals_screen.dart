import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/services/setup_service.dart';
import '../controllers/profile_setup_controller.dart';
import '../widgets/goal_card.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/wizard_scaffold.dart';

class HealthGoalsScreen extends ConsumerWidget {
  const HealthGoalsScreen({super.key});

  static const List<({String key, String label, IconData icon})> _goals = [
    (
      key: 'maintain_weight',
      label: 'Maintain Weight',
      icon: Icons.monitor_weight_outlined
    ),
    (key: 'lose_weight', label: 'Lose Weight', icon: Icons.trending_down),
    (
      key: 'gain_muscle',
      label: 'Gain Muscle',
      icon: Icons.fitness_center_outlined
    ),
    (
      key: 'general_health',
      label: 'General Health',
      icon: Icons.favorite_outline
    ),
  ];

  static const List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
  ];

  Future<void> _completeSetup(BuildContext context, WidgetRef ref) async {
    await SetupService.markSetupComplete();
    await SetupService.clearPendingUserInfo();
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(profileSetupControllerProvider);
    final notifier = ref.read(profileSetupControllerProvider.notifier);

    return WizardScaffold(
      currentStep: 3,
      totalSteps: 3,
      stepLabel: 'Step 3 of 3',
      onBack: () => context.go('/profile/budget-setup'),
      onNext: () => _completeSetup(context, ref),
      onSkip: () => _completeSetup(context, ref),
      nextLabel: 'Next',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your health goals?',
            style: AppTypography.headline1,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This helps us personalise your recommendations.',
            style: AppTypography.body2.copyWith(color: AppColors.neutral600),
          ),

          // ── Goal grid (2×2) ────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xxl),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GoalCard(
                      label: _goals[0].label,
                      icon: _goals[0].icon,
                      isSelected: data.healthGoal == _goals[0].key,
                      onTap: () => notifier.updateHealthGoals(
                          healthGoal: _goals[0].key),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GoalCard(
                      label: _goals[1].label,
                      icon: _goals[1].icon,
                      isSelected: data.healthGoal == _goals[1].key,
                      onTap: () => notifier.updateHealthGoals(
                          healthGoal: _goals[1].key),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: GoalCard(
                      label: _goals[2].label,
                      icon: _goals[2].icon,
                      isSelected: data.healthGoal == _goals[2].key,
                      onTap: () => notifier.updateHealthGoals(
                          healthGoal: _goals[2].key),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GoalCard(
                      label: _goals[3].label,
                      icon: _goals[3].icon,
                      isSelected: data.healthGoal == _goals[3].key,
                      onTap: () => notifier.updateHealthGoals(
                          healthGoal: _goals[3].key),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Activity level ─────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xxl),
          Text('Activity level', style: AppTypography.headline3),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _activityLevels.map((level) {
              final key = level.toLowerCase();
              return SelectableChip(
                label: level,
                isSelected: data.activityLevel == key,
                onTap: () => notifier.updateHealthGoals(activityLevel: key),
              );
            }).toList(),
          ),

          // ── Weight (optional) ──────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xxl),
          Text('Weight (optional)', style: AppTypography.headline3),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Weight (optional)',
            keyboardType: TextInputType.number,
            hint: 'e.g. 70',
            suffixIcon: Text(
              'kg',
              style: AppTypography.body2.copyWith(color: AppColors.neutral400),
            ),
            onChanged: (v) {
              final kg = double.tryParse(v);
              if (kg != null) {
                notifier.updateHealthGoals(weightKg: kg);
              }
            },
          ),
        ],
      ),
    );
  }
}
