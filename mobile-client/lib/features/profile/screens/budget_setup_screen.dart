import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/profile_setup_controller.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/wizard_scaffold.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const BudgetSetupScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  static const List<int> _presets = [60, 70, 80, 90];

  late final TextEditingController _alertController;
  late final TextEditingController _budgetController;
  late final FocusNode _budgetFocusNode;
  late final FocusNode _alertFocusNode;
  bool _editingBudget = false;
  late int _alertPreset;
  late bool _isCustomAlert;

  bool get _isEditMode => widget.isEditMode;

  @override
  void initState() {
    super.initState();
    final data = ref.read(profileSetupControllerProvider);
    final initial = data.alertThresholdPercent;
    _alertController = TextEditingController(text: initial.toString());
    _budgetController =
        TextEditingController(text: data.monthlyBudget.toStringAsFixed(0));
    _budgetFocusNode = FocusNode()..addListener(_onBudgetFocusChange);
    _alertFocusNode = FocusNode();
    _isCustomAlert = !_presets.contains(initial);
    _alertPreset = _isCustomAlert ? _presets[2] : initial;
  }

  @override
  void dispose() {
    _alertController.dispose();
    _budgetController.dispose();
    _budgetFocusNode.dispose();
    _alertFocusNode.dispose();
    super.dispose();
  }

  void _onBudgetFocusChange() {
    if (!_budgetFocusNode.hasFocus && _editingBudget) {
      _submitBudget();
    }
  }

  void _startEditingBudget() {
    final current = ref.read(profileSetupControllerProvider).monthlyBudget;
    _budgetController.text = current.toStringAsFixed(0);
    setState(() => _editingBudget = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _budgetFocusNode.requestFocus();
      _budgetController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _budgetController.text.length,
      );
    });
  }

  void _submitBudget() {
    final parsed = double.tryParse(_budgetController.text);
    final clamped = parsed?.clamp(100, 10000).toDouble();
    if (clamped != null) {
      _budgetController.text = clamped.toStringAsFixed(0);
      ref
          .read(profileSetupControllerProvider.notifier)
          .updateBudget(monthly: clamped);
    } else {
      final fallback =
          ref.read(profileSetupControllerProvider).monthlyBudget;
      _budgetController.text = fallback.toStringAsFixed(0);
    }
    setState(() => _editingBudget = false);
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

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(profileSetupControllerProvider);
    final notifier = ref.read(profileSetupControllerProvider.notifier);

    final estimatedPerMeal = data.monthlyBudget / 30 / 3;
    final totalAllocated = data.diningBudget + data.groceriesBudget;
    final overBudget = totalAllocated > data.monthlyBudget;
    final safeMax = data.monthlyBudget > 0 ? data.monthlyBudget : 1.0;

    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set your monthly food budget.',
            style: AppTypography.headline1,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Budget amount card ─────────────────────────────────────────────
          _SectionCard(
            child: Column(
              children: [
                if (_editingBudget)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'RM',
                        style: AppTypography.headline2
                            .copyWith(color: AppColors.neutral600),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _budgetController,
                          focusNode: _budgetFocusNode,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          style: AppTypography.budgetHero,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _submitBudget(),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _startEditingBudget,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'RM',
                          style: AppTypography.headline2
                              .copyWith(color: AppColors.neutral600),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          data.monthlyBudget.toStringAsFixed(0),
                          style: AppTypography.budgetHero,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _editingBudget ? 'Tap elsewhere to confirm' : 'Tap to change',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                _EstimatedMealChip(estimatedPerMeal: estimatedPerMeal),
              ],
            ),
          ),

          // ── Category split ─────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Category split', style: AppTypography.headline3),
                    Text('Optional', style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _CategorySlider(
                  icon: Icons.restaurant_outlined,
                  label: 'Dining Out',
                  value: data.diningBudget,
                  max: safeMax,
                  onChanged: (v) => notifier.updateBudget(dining: v),
                ),
                const SizedBox(height: AppSpacing.md),
                _CategorySlider(
                  icon: Icons.local_grocery_store_outlined,
                  label: 'Groceries',
                  value: data.groceriesBudget,
                  max: safeMax,
                  onChanged: (v) => notifier.updateBudget(groceries: v),
                ),
                if (overBudget) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Allocations exceed budget',
                    style:
                        AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ],
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
      return Scaffold(
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
            onPressed: () => context.pop(),
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
                label: 'Save',
                onPressed: () => context.pop(),
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

class _CategorySlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const _CategorySlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: AppSpacing.iconXs, color: AppColors.neutral600),
                const SizedBox(width: AppSpacing.xs),
                Text(label, style: AppTypography.body1),
              ],
            ),
            Text(
              'RM ${value.toStringAsFixed(0)}',
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Slider(
          min: 0,
          max: max,
          value: value.clamp(0, max),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
