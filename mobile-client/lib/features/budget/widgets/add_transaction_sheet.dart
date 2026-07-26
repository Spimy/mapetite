import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/store_providers.dart';
import '../models/budget_transaction.dart';
import '../providers/budget_provider.dart';

void showAddTransactionSheet(
  BuildContext context, {
  BudgetTransaction? existing,
}) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: _AddTransactionSheet(existing: existing),
    ),
  );
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  final BudgetTransaction? existing;
  const _AddTransactionSheet({this.existing});

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  BudgetCategory _category = BudgetCategory.dining;
  DateTime _selectedDate = DateTime.now();
  StoreModel? _selectedStore;
  // Tracks the linked store's id independently of _selectedStore (which only
  // holds a full StoreModel once the picker has been used this session), so
  // an edit that never reopens the picker still preserves the original link.
  String? _selectedStoreId;
  bool _isSaving = false;
  bool _isLoadingStores = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existing!;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _category = e.category;
      _selectedDate = e.dateSpent;
      _nameCtrl.text = e.storeName ?? '';
      _notesCtrl.text = e.notes ?? '';
      _selectedStoreId = e.storeId;
    }
    _amountCtrl.addListener(() => setState(() {}));
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  double get _parsedAmount => double.tryParse(_amountCtrl.text) ?? 0.0;
  bool get _isValid => _parsedAmount > 0 && _nameCtrl.text.trim().isNotEmpty;

  StoreType get _storeTypeForCategory =>
      _category == BudgetCategory.dining ? StoreType.restaurant : StoreType.grocery;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today, ${DateFormat('d MMM yyyy').format(dt)}';
    return DateFormat('EEEE, d MMM yyyy').format(dt);
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

  Future<void> _pickStore() async {
    if (_isLoadingStores) return;
    setState(() => _isLoadingStores = true);
    List<StoreModel> stores;
    try {
      stores = await ref.read(storesProvider(_storeTypeForCategory).future);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingStores = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load stores. Please try again.',
              style: AppTypography.body1.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isLoadingStores = false);
    final picked = await showModalBottomSheet<StoreModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StorePickerSheet(stores: stores),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedStore = picked;
        _selectedStoreId = picked.id;
        _nameCtrl.text = picked.businessName;
      });
    }
  }

  Future<void> _save() async {
    if (!_isValid) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final draft = BudgetTransactionDraft(
      storeId: _selectedStore?.id ?? _selectedStoreId,
      name: _nameCtrl.text.trim(),
      category: _category,
      amount: _parsedAmount,
      dateSpent: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
      ),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      final displayName = _selectedStore?.businessName ?? _nameCtrl.text.trim();
      if (_isEditing) {
        await ref.read(budgetProvider.notifier).editTransaction(
              widget.existing!.id,
              draft,
              draftDisplayName: displayName,
            );
      } else {
        await ref
            .read(budgetProvider.notifier)
            .addTransaction(draft, draftDisplayName: displayName);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Transaction updated' : 'Transaction saved',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save transaction. Please try again.',
              style: AppTypography.body1.copyWith(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, bottomInset + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral400,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(
                  _isEditing ? 'Edit Transaction' : 'Add Transaction',
                  style: AppTypography.headline2,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.neutral600),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Large amount input ─────────────────────────────────────────
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'RM',
                    style: AppTypography.headline1.copyWith(
                        color: AppColors.neutral400, fontSize: 20),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _amountCtrl,
                      focusNode: _amountFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      style: AppTypography.budgetHero,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.]')),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: AppTypography.budgetHero.copyWith(
                          color: AppColors.neutral200,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Category selector ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _CatCard(
                  icon: Icons.restaurant_outlined,
                  label: 'Dining Out',
                  selected: _category == BudgetCategory.dining,
                  onTap: () => setState(() {
                    _category = BudgetCategory.dining;
                    _selectedStore = null;
                    _selectedStoreId = null;
                  }),
                )),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _CatCard(
                  icon: Icons.local_grocery_store_outlined,
                  label: 'Cook-In',
                  selected: _category == BudgetCategory.groceries,
                  onTap: () => setState(() {
                    _category = BudgetCategory.groceries;
                    _selectedStore = null;
                    _selectedStoreId = null;
                  }),
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Name / place ──────────────────────────────────────────────
            AppTextField(
              label: 'Item / Place',
              controller: _nameCtrl,
              hint: 'e.g. Jaya Grocer',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Store picker (optional — links a registered store) ────────
            GestureDetector(
              onTap: _isLoadingStores ? null : _pickStore,
              child: Container(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: AppSpacing.iconSm, color: AppColors.neutral400),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _selectedStore?.businessName ??
                            'Link a store (optional)',
                        style: AppTypography.body1,
                      ),
                    ),
                    if (_isLoadingStores)
                      const SizedBox(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.neutral400),
                      )
                    else
                      const Icon(Icons.chevron_right,
                          size: AppSpacing.iconSm,
                          color: AppColors.neutral400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Date row ───────────────────────────────────────────────────
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: AppSpacing.iconSm,
                        color: AppColors.neutral400),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(_formatDate(_selectedDate),
                          style: AppTypography.body1),
                    ),
                    const Icon(Icons.chevron_right,
                        size: AppSpacing.iconSm,
                        color: AppColors.neutral400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Notes ──────────────────────────────────────────────────────
            TextField(
              controller: _notesCtrl,
              style: AppTypography.body1,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: AppTypography.body1
                    .copyWith(color: AppColors.neutral400),
                filled: true,
                fillColor: AppColors.neutral100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: _isSaving
                  ? 'Saving...'
                  : (_isEditing ? 'Save Changes' : 'Save Transaction'),
              isLoading: _isSaving,
              onPressed: _isValid && !_isSaving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePickerSheet extends StatelessWidget {
  final List<StoreModel> stores;
  const _StorePickerSheet({required this.stores});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('Select a store', style: AppTypography.headline2),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: stores.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text('No stores found nearby.',
                        style: AppTypography.body2),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: stores.length,
                    itemBuilder: (context, i) {
                      final store = stores[i];
                      return ListTile(
                        title: Text(store.businessName),
                        onTap: () => Navigator.of(context).pop(store),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _CatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatCard({
    required this.icon,
    required this.label,
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
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.background : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: AppSpacing.iconMd,
                color: selected ? AppColors.primary : AppColors.neutral600),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.body2.copyWith(
                color: selected ? AppColors.primary : AppColors.neutral600,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
