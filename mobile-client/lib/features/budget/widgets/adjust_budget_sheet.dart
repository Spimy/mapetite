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
  late TextEditingController _groceryCtrl;
  late TextEditingController _dineInCtrl;

  late double _initialGrocery;
  late double _initialDineIn;

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final b = ref.read(budgetProvider).value;
    _initialGrocery = b?.groceryBudget ?? 0;
    _initialDineIn = b?.dineInBudget ?? 0;
    _groceryCtrl = TextEditingController(text: _initialGrocery.toStringAsFixed(0))
      ..addListener(_onChanged);
    _dineInCtrl = TextEditingController(text: _initialDineIn.toStringAsFixed(0))
      ..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _groceryCtrl.dispose();
    _dineInCtrl.dispose();
    super.dispose();
  }

  double get _grocery => double.tryParse(_groceryCtrl.text) ?? _initialGrocery;
  double get _dineIn => double.tryParse(_dineInCtrl.text) ?? _initialDineIn;

  bool get _isDirty => _grocery != _initialGrocery || _dineIn != _initialDineIn;

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(budgetProvider.notifier).adjustBudget(
            dineIn: _dineIn,
            grocery: _grocery,
          );
      ref.read(profileSetupControllerProvider.notifier).updateBudget(
            dineIn: _dineIn,
            grocery: _grocery,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget updated',
              style: AppTypography.body1.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    } catch (_) {
      setState(() => _error = 'Could not save your budget. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              label: 'Dine-In Budget',
              controller: _dineInCtrl,
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
              controller: _groceryCtrl,
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
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
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
