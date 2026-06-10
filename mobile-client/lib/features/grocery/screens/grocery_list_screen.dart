import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/grocery_list_model.dart';
import '../models/mocks/grocery_list_mocks.dart';
import '../providers/grocery_list_provider.dart';
import '../widgets/grocery_item_tile.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AddItemSheet(
          onAdd: (item) => ref.read(groceryListProvider.notifier).addItem(item),
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _MoreMenuSheet(
        onClearCompleted: () {
          Navigator.of(context).pop();
          ref.read(groceryListProvider.notifier).clearCompleted();
        },
        onClearAll: () {
          Navigator.of(context).pop();
          _showClearAllDialog();
        },
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 32),
        title: Text('Clear Grocery List?', style: AppTypography.headline2),
        content: Text(
          'This will remove all items from your list. This action cannot be undone.',
          style: AppTypography.body2.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('Cancel', style: AppTypography.button.copyWith(color: AppColors.neutral)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(groceryListProvider.notifier).clearAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('Clear List', style: AppTypography.button),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(groceryListProvider);
    final total = ref.watch(groceryTotalProvider);
    final showAlert = ref.watch(groceryBudgetAlertProvider);
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 2,
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Text('My List', style: AppTypography.headline2),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '${items.length} item${items.length != 1 ? 's' : ''}',
                style: AppTypography.label.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showMoreMenu,
            icon: const Icon(Icons.more_vert, color: AppColors.neutral),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _ItemsCard(
                    unchecked: unchecked,
                    checked: checked,
                    onToggle: (id) => ref.read(groceryListProvider.notifier).toggleItem(id),
                    onDelete: (id) => ref.read(groceryListProvider.notifier).removeItem(id),
                    onAddItem: _showAddItemSheet,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryCard(
                    total: total,
                    showAlert: showAlert,
                    weeklyLimit: GroceryListMocks.weeklyBudgetLimit,
                    hasCompleted: checked.isNotEmpty,
                    onClearCompleted: () =>
                        ref.read(groceryListProvider.notifier).clearCompleted(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          _PlanRouteButton(),
        ],
      ),
    );
  }
}

// ─── Items Card ───────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final List<GroceryListItem> unchecked;
  final List<GroceryListItem> checked;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final VoidCallback onAddItem;

  const _ItemsCard({
    required this.unchecked,
    required this.checked,
    required this.onToggle,
    required this.onDelete,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...unchecked.map((item) => GroceryItemTile(
                item: item,
                onToggle: () => onToggle(item.id),
                onDelete: () => onDelete(item.id),
              )),
          if (checked.isNotEmpty) ...[
            const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
            ...checked.map((item) => GroceryItemTile(
                  item: item,
                  onToggle: () => onToggle(item.id),
                  onDelete: () => onDelete(item.id),
                )),
          ],
          const Divider(color: AppColors.border, height: 1),
          _AddItemButton(onTap: onAddItem),
        ],
      ),
    );
  }
}

// ─── Add Item Button ──────────────────────────────────────────────────────────

class _AddItemButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddItemButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add item',
                style: AppTypography.body1.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Item Sheet ───────────────────────────────────────────────────────────

class _AddItemSheet extends StatefulWidget {
  final ValueChanged<GroceryListItem> onAdd;

  const _AddItemSheet({required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _storeCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(
      GroceryListItem(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        quantity: _quantityCtrl.text.trim().isEmpty ? '1' : _quantityCtrl.text.trim(),
        storeName: _storeCtrl.text.trim().isEmpty ? '' : _storeCtrl.text.trim(),
        estimatedPrice: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Add Item', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.lg),
          const _FieldLabel('Item name'),
          const SizedBox(height: AppSpacing.xs),
          _SheetField(
            controller: _nameCtrl,
            hint: 'e.g. Organic Eggs',
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Quantity'),
                    const SizedBox(height: AppSpacing.xs),
                    _SheetField(
                      controller: _quantityCtrl,
                      hint: 'e.g. 2 pcs',
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Est. Cost (RM)'),
                    const SizedBox(height: AppSpacing.xs),
                    _SheetField(
                      controller: _priceCtrl,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _FieldLabel('Store'),
          const SizedBox(height: AppSpacing.xs),
          _SheetField(
            controller: _storeCtrl,
            hint: 'e.g. Fresh Mart',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('Add to List', style: AppTypography.button),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.label.copyWith(color: AppColors.neutral700),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _SheetField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: AppTypography.body1.copyWith(color: AppColors.neutral),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double total;
  final bool showAlert;
  final double weeklyLimit;
  final bool hasCompleted;
  final VoidCallback onClearCompleted;

  const _SummaryCard({
    required this.total,
    required this.showAlert,
    required this.weeklyLimit,
    required this.hasCompleted,
    required this.onClearCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Estimated Total',
                style: AppTypography.headline3.copyWith(color: AppColors.neutral),
              ),
              Text(
                'RM ${total.toStringAsFixed(2)}',
                style: AppTypography.headline1.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (showAlert) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Alert',
                          style: AppTypography.label.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You are nearing your RM ${weeklyLimit.toStringAsFixed(2)} grocery budget limit for this week.',
                          style: AppTypography.body2.copyWith(color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: GestureDetector(
                onTap: onClearCompleted,
                child: Text(
                  'Clear completed items',
                  style: AppTypography.body2.copyWith(color: AppColors.neutral400),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Plan Route Button ────────────────────────────────────────────────────────

class _PlanRouteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg,
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Shopping route planning coming soon!',
                    style: AppTypography.body1.copyWith(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.route_outlined, size: 20),
            label: Text('Plan Shopping Route', style: AppTypography.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── More Menu Sheet ──────────────────────────────────────────────────────────

class _MoreMenuSheet extends StatelessWidget {
  final VoidCallback onClearCompleted;
  final VoidCallback onClearAll;

  const _MoreMenuSheet({required this.onClearCompleted, required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.neutral600),
            title: Text('Clear completed items', style: AppTypography.body1),
            onTap: onClearCompleted,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
            title: Text(
              'Clear grocery list',
              style: AppTypography.body1.copyWith(color: AppColors.error),
            ),
            onTap: onClearAll,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
