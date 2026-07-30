import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/profile_setup_controller.dart';
import '../models/profile_setup_data.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/unsaved_changes_dialog.dart';
import '../widgets/wizard_scaffold.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const BudgetSetupScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  static const List<int> _presets = [60, 70, 80, 90];

  late ProfileSetupData _initial;
  late final TextEditingController _alertController;
  late final TextEditingController _dineInController;
  late final TextEditingController _groceryController;
  late final FocusNode _alertFocusNode;
  late int _alertPreset;
  late bool _isCustomAlert;

  bool get _isEditMode => widget.isEditMode;

  @override
  void initState() {
    super.initState();
    final data = ref.read(profileSetupControllerProvider);
    _initial = data;
    final initial = data.alertThresholdPercent;
    _alertController = TextEditingController(text: initial.toString());
    _dineInController =
        TextEditingController(text: data.dineInBudget.toStringAsFixed(0));
    _groceryController =
        TextEditingController(text: data.groceryBudget.toStringAsFixed(0));
    _alertFocusNode = FocusNode();
    _isCustomAlert = !_presets.contains(initial);
    _alertPreset = _isCustomAlert ? _presets[2] : initial;
  }

  @override
  void dispose() {
    _alertController.dispose();
    _dineInController.dispose();
    _groceryController.dispose();
    _alertFocusNode.dispose();
    super.dispose();
  }

  void _onDineInChanged(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return;
    ref.read(profileSetupControllerProvider.notifier).updateBudget(dineIn: parsed);
  }

  void _onGroceryChanged(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return;
    ref.read(profileSetupControllerProvider.notifier).updateBudget(grocery: parsed);
  }

  void _onAlertChanged(String raw) {
    final pct = int.tryParse(raw);
    if (pct == null) return;
    ref
        .read(profileSetupControllerProvider.notifier)
        .updateBudget(alertThreshold: pct.clamp(1, 100));
  }

  void _selectPreset(int value) {
    setState(() {
      _alertPreset = value;
      _isCustomAlert = false;
    });
    _alertController.text = value.toString();
    ref
        .read(profileSetupControllerProvider.notifier)
        .updateBudget(alertThreshold: value);
  }

  void _selectCustom() {
    setState(() => _isCustomAlert = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _alertFocusNode.requestFocus(),
    );
  }

  bool _hasUnsavedChanges(ProfileSetupData current) {
    return current.dineInBudget != _initial.dineInBudget ||
        current.groceryBudget != _initial.groceryBudget ||
        current.alertThresholdPercent != _initial.alertThresholdPercent;
  }

  void _discardAndPop() {
    ref.read(profileSetupControllerProvider.notifier).updateBudget(
      dineIn: _initial.dineInBudget,
      grocery: _initial.groceryBudget,
      alertThreshold: _initial.alertThresholdPercent,
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

    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set your monthly food budget.',
            style: AppTypography.headline1,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Category budgets ─────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Dining Out',
                  controller: _dineInController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Align(
                      widthFactor: 1.0,
                      child: Text('RM',
                          style: TextStyle(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onDineInChanged,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Groceries',
                  controller: _groceryController,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Align(
                      widthFactor: 1.0,
                      child: Text('RM',
                          style: TextStyle(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onGroceryChanged,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.md),
                _EstimatedMealChip(
                  estimatedPerMeal: data.monthlyBudget / 30 / 3,
                ),
              ],
            ),
          ),

          // ── Alert threshold ────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      size: AppSpacing.iconSm,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Spending alert', style: AppTypography.headline3),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Notify me when I have used',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ..._presets.map(
                      (pct) => SelectableChip(
                        label: '$pct%',
                        isSelected: !_isCustomAlert && _alertPreset == pct,
                        onTap: () => _selectPreset(pct),
                      ),
                    ),
                    SelectableChip(
                      label: 'Custom',
                      isSelected: _isCustomAlert,
                      onTap: _selectCustom,
                    ),
                  ],
                ),
                if (_isCustomAlert) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Width and vertical padding match SelectableChip exactly.
                      SizedBox(
                        width: AppSpacing.xxxl + AppSpacing.xs,
                        child: TextFormField(
                          controller: _alertController,
                          focusNode: _alertFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: AppTypography.label,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs + 2,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            hintText: '1–100',
                            hintStyle: AppTypography.label.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                          onChanged: _onAlertChanged,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('% of my budget', style: AppTypography.body2),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
    );

    if (_isEditMode) {
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
            title: const Text('Budget Settings'),
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
      currentStep: 2,
      totalSteps: 3,
      stepLabel: 'Step 2 of 3',
      onBack: () => context.go('/profile/dietary'),
      onNext: () => context.go('/profile/health-goals'),
      onSkip: () => context.go('/profile/health-goals'),
      nextLabel: 'Next',
      body: body,
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

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
      child: child,
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _EstimatedMealChip extends StatelessWidget {
  final double estimatedPerMeal;

  const _EstimatedMealChip({required this.estimatedPerMeal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Estimated per meal: RM ${estimatedPerMeal.toStringAsFixed(2)}',
            style: AppTypography.body2.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
