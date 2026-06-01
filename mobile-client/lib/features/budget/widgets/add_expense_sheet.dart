import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/budget_transaction.dart';
import '../providers/budget_provider.dart';

void showAddExpenseSheet(BuildContext context, [WidgetRef? ref]) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: const _AddExpenseSheet(),
    ),
  );
}

class _AddExpenseSheet extends ConsumerStatefulWidget {
  const _AddExpenseSheet();

  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  BudgetCategory? _category;
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onChanged);
    _amountCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _category != null &&
      _nameCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_amountCtrl.text) ?? 0) > 0;

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(dt.year, dt.month, dt.day);
    if (txDay == today) return 'Today';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_isValid) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    final now = DateTime.now();
    final txDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
    );

    ref.read(budgetProvider.notifier).addTransaction(BudgetTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      category: _category!,
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      dateTime: txDateTime,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    ));

    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text('Expense added',
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, bottom + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral400,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text('Add Expense',
                  style: AppTypography.headline2, textAlign: TextAlign.center),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Category selection
            Text('Category',
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _CategoryChip(
                    label: 'Groceries',
                    icon: Icons.local_grocery_store_outlined,
                    selected: _category == BudgetCategory.groceries,
                    onTap: () =>
                        setState(() => _category = BudgetCategory.groceries),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _CategoryChip(
                    label: 'Dining Out',
                    icon: Icons.restaurant_outlined,
                    selected: _category == BudgetCategory.dining,
                    onTap: () =>
                        setState(() => _category = BudgetCategory.dining),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              label: 'Item / Place',
              controller: _nameCtrl,
              hint: 'e.g. Jaya Grocer',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              label: 'Amount',
              controller: _amountCtrl,
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date field
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Date',
                  controller:
                      TextEditingController(text: _dateLabel(_selectedDate)),
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      size: AppSpacing.iconSm, color: AppColors.neutral400),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              label: 'Notes (optional)',
              controller: _notesCtrl,
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: _isSaving ? 'Saving...' : 'Save Expense',
              isLoading: _isSaving,
              onPressed: _isValid && !_isSaving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: AppSpacing.iconSm,
                color: selected ? AppColors.primary : AppColors.neutral600),
            const SizedBox(width: AppSpacing.xs),
            Text(label,
                style: AppTypography.body1.copyWith(
                  color: selected ? AppColors.primary : AppColors.neutral,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}
