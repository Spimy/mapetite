import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/budget_provider.dart';
import '../../profile/controllers/profile_setup_controller.dart';

void showAdjustBudgetSheet(BuildContext context, [WidgetRef? ref]) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: const _AdjustBudgetSheet(),
    ),
  );
}

class _AdjustBudgetSheet extends ConsumerStatefulWidget {
  const _AdjustBudgetSheet();

  @override
  ConsumerState<_AdjustBudgetSheet> createState() => _AdjustBudgetSheetState();
}

class _AdjustBudgetSheetState extends ConsumerState<_AdjustBudgetSheet> {
  late TextEditingController _monthlyCtrl;
  late TextEditingController _groceriesCtrl;
  late TextEditingController _diningCtrl;

  late double _initialMonthly;
  late double _initialGroceries;
  late double _initialDining;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = ref.read(budgetProvider);
    _initialMonthly = b.monthlyBudget;
    _initialGroceries = b.groceriesBudget;
    _initialDining = b.diningBudget;
    _monthlyCtrl = TextEditingController(text: b.monthlyBudget.toStringAsFixed(0))
      ..addListener(_onChanged);
    _groceriesCtrl = TextEditingController(text: b.groceriesBudget.toStringAsFixed(0))
      ..addListener(_onChanged);
    _diningCtrl = TextEditingController(text: b.diningBudget.toStringAsFixed(0))
      ..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _groceriesCtrl.dispose();
    _diningCtrl.dispose();
    super.dispose();
  }

  double get _monthly => double.tryParse(_monthlyCtrl.text) ?? _initialMonthly;
  double get _groceries => double.tryParse(_groceriesCtrl.text) ?? _initialGroceries;
  double get _dining => double.tryParse(_diningCtrl.text) ?? _initialDining;

  bool get _isDirty =>
      _monthly != _initialMonthly ||
      _groceries != _initialGroceries ||
      _dining != _initialDining;

  bool get _isOverBudget => (_groceries + _dining) > _monthly;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    ref.read(budgetProvider.notifier).adjustBudget(
          monthly: _monthly,
          groceries: _groceries,
          dining: _dining,
        );
    // Keep profile setup in sync
    ref.read(profileSetupControllerProvider.notifier).updateBudget(
          monthly: _monthly,
          groceries: _groceries,
          dining: _dining,
        );
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text('Budget updated',
                    style: AppTypography.body1.copyWith(color: AppColors.white)),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 14),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved changes will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Discard',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final ok = await _confirmDiscard();
          if (ok && mounted) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl)),
        ),
        padding:
            EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom + AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Handle
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Adjust Budget',
                style: AppTypography.headline2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Total Monthly Budget',
              controller: _monthlyCtrl,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Align(
                  widthFactor: 1.0,
                  child: Text('RM',
                      style: TextStyle(
                          color: AppColors.neutral600, fontWeight: FontWeight.w600)),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Groceries Budget',
              controller: _groceriesCtrl,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Align(
                  widthFactor: 1.0,
                  child: Text('RM',
                      style: TextStyle(
                          color: AppColors.neutral600, fontWeight: FontWeight.w600)),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Dining Out Budget',
              controller: _diningCtrl,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Align(
                  widthFactor: 1.0,
                  child: Text('RM',
                      style: TextStyle(
                          color: AppColors.neutral600, fontWeight: FontWeight.w600)),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
            ),
            if (_isOverBudget) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Category budgets exceed monthly total',
                style: AppTypography.caption.copyWith(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: _isSaving ? 'Saving...' : 'Save Changes',
              isLoading: _isSaving,
              onPressed: (_isSaving || !_isDirty) ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
