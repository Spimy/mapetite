import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_setup_controller.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/wizard_scaffold.dart';

class DietaryPreferencesScreen extends ConsumerWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(profileSetupControllerProvider);
    final notifier = ref.read(profileSetupControllerProvider.notifier);

    return WizardScaffold(
      currentStep: 1,
      totalSteps: 3,
      stepLabel: 'Step 1 of 3',
      onNext: () => context.go('/profile/budget-setup'),
      onSkip: () => context.go('/profile/budget-setup'),
      nextLabel: 'Next',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get started.", style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We need a few details to personalise your food experience.',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('What do you eat?', style: AppTypography.headline1),
          const SizedBox(height: AppSpacing.lg),

          // ── Dietary requirements ───────────────────────────────────────────
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

          // ── Allergens ──────────────────────────────────────────────────────
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

          // ── Calorie target ─────────────────────────────────────────────────
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
                      style: AppTypography.headline3
                          .copyWith(color: AppColors.primary),
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
                  onChanged: (v) =>
                      notifier.updateDietary(dailyCalorieTarget: v.round()),
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

          // ── Cuisine preferences ────────────────────────────────────────────
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
      ),
    );
  }
}

// ── Private widgets ─────────────────────────────────────────────────────────

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
