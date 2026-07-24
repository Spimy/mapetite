import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/setup_service.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_setup_controller.dart';
import '../models/profile_setup_data.dart';
import '../widgets/goal_card.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/unsaved_changes_dialog.dart';
import '../widgets/wizard_scaffold.dart';

class HealthGoalsScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const HealthGoalsScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<HealthGoalsScreen> createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends ConsumerState<HealthGoalsScreen> {
  static const List<({String key, String label, IconData icon})> _goals = [
    (
      key: 'maintain_weight',
      label: 'Maintain Weight',
      icon: Icons.monitor_weight_outlined,
    ),
    (
      key: 'lose_weight',
      label: 'Lose Weight',
      icon: Icons.trending_down,
    ),
    (
      key: 'gain_muscle',
      label: 'Gain Muscle',
      icon: Icons.fitness_center_outlined,
    ),
    (
      key: 'general_health',
      label: 'General Health',
      icon: Icons.favorite_outline,
    ),
  ];

  static const List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
  ];

  late ProfileSetupData _initial;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _initial = ref.read(profileSetupControllerProvider);
  }

  bool _hasUnsavedChanges(ProfileSetupData current) {
    return current.healthGoal != _initial.healthGoal ||
        current.activityLevel != _initial.activityLevel ||
        current.weightKg != _initial.weightKg;
  }

  void _discardAndPop() {
    ref.read(profileSetupControllerProvider.notifier).updateHealthGoals(
          healthGoal: _initial.healthGoal,
          activityLevel: _initial.activityLevel,
          weightKg: _initial.weightKg,
        );

    context.pop();
  }

  void _handlePopAttempt(bool hasUnsaved) async {
    if (!hasUnsaved) {
      context.pop();
      return;
    }

    final discard = await showUnsavedChangesDialog(context);

    if (discard && mounted) {
      _discardAndPop();
    }
  }

  Future<void> _completeSetup() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ref.read(profileSetupControllerProvider.notifier).submitSetup();

      await SetupService.clearPendingUserInfo();

      await ref.read(authControllerProvider.notifier).loadCurrentUser();

      if (mounted) {
        context.go('/home');
      }
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submitError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submitError = 'Unable to save profile setup. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(profileSetupControllerProvider);
    final notifier = ref.read(profileSetupControllerProvider.notifier);

    final body = Column(
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
                      healthGoal: _goals[0].key,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GoalCard(
                    label: _goals[1].label,
                    icon: _goals[1].icon,
                    isSelected: data.healthGoal == _goals[1].key,
                    onTap: () => notifier.updateHealthGoals(
                      healthGoal: _goals[1].key,
                    ),
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
                      healthGoal: _goals[2].key,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GoalCard(
                    label: _goals[3].label,
                    icon: _goals[3].icon,
                    isSelected: data.healthGoal == _goals[3].key,
                    onTap: () => notifier.updateHealthGoals(
                      healthGoal: _goals[3].key,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        if (_submitError != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _submitError!,
            style: AppTypography.body2.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );

    if (widget.isEditMode) {
      final hasUnsaved = _hasUnsavedChanges(data);

      return PopScope(
        canPop: !hasUnsaved,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _handlePopAttempt(hasUnsaved);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: AppTypography.headline2.copyWith(
              color: AppColors.primary,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handlePopAttempt(hasUnsaved),
            ),
            title: const Text('Health Goals'),
            centerTitle: true,
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontalPadding,
                    ).copyWith(
                      top: AppSpacing.xxl,
                      bottom: AppSpacing.xl,
                    ),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: 'Done',
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return WizardScaffold(
      currentStep: 3,
      totalSteps: 3,
      stepLabel: 'Step 3 of 3',
      onBack: _isSubmitting ? () {} : () => context.go('/profile/budget-setup'),
      onNext: _isSubmitting ? () {} : () => _completeSetup(),
      onSkip: _isSubmitting ? () {} : () => _completeSetup(),
      nextLabel: _isSubmitting ? 'Saving...' : 'Next',
      body: body,
    );
  }
}