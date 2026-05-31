import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/profile_setup_controller.dart';
import '../models/profile_setup_data.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/unsaved_changes_dialog.dart';
import '../widgets/wizard_scaffold.dart';

class DietaryPreferencesScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const DietaryPreferencesScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<DietaryPreferencesScreen> createState() =>
      _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState
    extends ConsumerState<DietaryPreferencesScreen> {
  late ProfileSetupData _initial;

  @override
  void initState() {
    super.initState();
    _initial = ref.read(profileSetupControllerProvider);
  }

  bool _hasUnsavedChanges(ProfileSetupData current) {
    return current.isHalal != _initial.isHalal ||
        current.isVegetarian != _initial.isVegetarian ||
        current.isVegan != _initial.isVegan ||
        !listEquals(current.allergens, _initial.allergens) ||
        current.dailyCalorieTarget != _initial.dailyCalorieTarget ||
        !listEquals(current.cuisinePreferences, _initial.cuisinePreferences);
  }

  void _discardAndPop() {
    ref.read(profileSetupControllerProvider.notifier).updateDietary(
      isHalal: _initial.isHalal,
      isVegetarian: _initial.isVegetarian,
      isVegan: _initial.isVegan,
      allergens: List<String>.from(_initial.allergens),
      dailyCalorieTarget: _initial.dailyCalorieTarget,
      cuisinePreferences: List<String>.from(_initial.cuisinePreferences),
    );
    context.pop();
  }

  void _handlePopAttempt(bool hasUnsaved) async {
    if (!hasUnsaved) {
      context.pop();
      return;
    }
    final discard = await showUnsavedChangesDialog(context);
    if (discard && mounted) _discardAndPop();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(profileSetupControllerProvider);
    final notifier = ref.read(profileSetupControllerProvider.notifier);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isEditMode) ...[
          Text("Let's get started.", style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We need a few details to personalise your food experience.',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        Text('What do you eat?', style: AppTypography.headline1),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: 'Dietary requirements',
          child: Column(
            children: [
              _ToggleRow(
                label: 'Halal',
                value: data.isHalal,
                onChanged: (v) => notifier.updateDietary(isHalal: v),
              ),
              _ToggleRow(
                label: 'Vegetarian',
                value: data.isVegetarian,
                onChanged: (v) => notifier.updateDietary(isVegetarian: v),
              ),
              _ToggleRow(
                label: 'Vegan',
                value: data.isVegan,
                onChanged: (v) => notifier.updateDietary(isVegan: v),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Allergens to avoid',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.allergenOptions.map((allergen) {
              return SelectableChip(
                label: allergen,
                isSelected: data.allergens.contains(allergen),
                onTap: () => notifier.toggleAllergen(allergen),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Daily calorie target',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target', style: AppTypography.body2),
                  Text(
                    '${data.dailyCalorieTarget} kcal',
                    style: AppTypography.headline3.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Slider(
                min: 1200,
                max: 3500,
                value: data.dailyCalorieTarget.toDouble(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (v) => notifier.updateDietary(dailyCalorieTarget: v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1200 kcal', style: AppTypography.caption),
                  Text('3500 kcal', style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Cuisine preferences',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.cuisineCategories.map((cuisine) {
              return SelectableChip(
                label: cuisine,
                isSelected: data.cuisinePreferences.contains(cuisine),
                onTap: () => notifier.toggleCuisine(cuisine),
              );
            }).toList(),
          ),
        ),
      ],
    );

    if (widget.isEditMode) {
      final hasUnsaved = _hasUnsavedChanges(data);
      return PopScope(
        canPop: !hasUnsaved,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handlePopAttempt(hasUnsaved);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: AppTypography.headline2.copyWith(color: AppColors.primary),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handlePopAttempt(hasUnsaved),
            ),
            title: const Text('Dietary Preferences'),
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
                    ).copyWith(top: AppSpacing.xxl, bottom: AppSpacing.xl),
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
                border: Border(top: BorderSide(color: AppColors.border)),
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
      currentStep: 1,
      totalSteps: 3,
      stepLabel: 'Step 1 of 3',
      onNext: () => context.go('/profile/budget-setup'),
      onSkip: () => context.go('/profile/budget-setup'),
      nextLabel: 'Next',
      body: body,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headline3),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.touchTarget,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body1),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
            inactiveThumbColor: AppColors.neutral400,
            inactiveTrackColor: AppColors.neutral200,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
