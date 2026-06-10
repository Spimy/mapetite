import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/profile_drawer.dart';
import '../../../features/grocery/models/grocery_list_model.dart';
import '../../../features/grocery/providers/grocery_list_provider.dart';
import '../../../features/recipes/providers/selected_ingredients_provider.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
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
        title: Text('Clear My List?', style: AppTypography.headline2),
        content: Text(
          'This will remove all items from your list. This cannot be undone.',
          style: AppTypography.body2.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neutral,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text('Cancel',
                      style: AppTypography.button
                          .copyWith(color: AppColors.neutral)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(groceryListProvider);
    final total = ref.watch(groceryTotalProvider);
    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();
    final isEmpty = items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ProfileDrawer(),
      appBar: _buildAppBar(context, items.length),
      body: SafeArea(
        top: false,
        child: isEmpty
            ? _buildEmptyState(context)
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _buildRecipeSourceCard(),
                          const SizedBox(height: AppSpacing.md),
                          _buildItemList(context, unchecked, checked),
                          const SizedBox(height: AppSpacing.md),
                          _buildAddItemRow(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSummaryCard(
                            context,
                            total,
                            checked.isNotEmpty,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                  _buildStickyFooter(context),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int itemCount) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
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
        mainAxisSize: MainAxisSize.min,
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
              '$itemCount item${itemCount != 1 ? 's' : ''}',
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
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      icon: Icons.shopping_basket_outlined,
      title: 'Your list is empty',
      description: 'Find a recipe to start adding ingredients.',
      ctaLabel: 'Browse Recipes',
      onCta: () => context.push('/recipes'),
    );
  }

  Widget _buildRecipeSourceCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From Recipe',
                style: AppTypography.label.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text('Nasi Goreng Kampung', style: AppTypography.headline3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    List<GroceryListItem> unchecked,
    List<GroceryListItem> checked,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ...unchecked.map((item) => _ListItemTile(
                item: item,
                onToggle: () =>
                    ref.read(groceryListProvider.notifier).toggleItem(item.id),
                onDelete: () =>
                    ref.read(groceryListProvider.notifier).removeItem(item.id),
              )),
          if (checked.isNotEmpty) ...[
            if (unchecked.isNotEmpty)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
            ...checked.map((item) => _ListItemTile(
                  item: item,
                  onToggle: () =>
                      ref.read(groceryListProvider.notifier).toggleItem(item.id),
                  onDelete: () =>
                      ref.read(groceryListProvider.notifier).removeItem(item.id),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildAddItemRow() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _showAddItemSheet,
        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
        label: Text(
          'Add item',
          style: AppTypography.button.copyWith(color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    double total,
    bool hasCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated total', style: AppTypography.body1),
              Text(
                'RM ${total.toStringAsFixed(2)}',
                style: AppTypography.headline2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.storefront,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '2 stores: Jaya Grocer + Village Grocer',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (hasCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    ref.read(groceryListProvider.notifier).clearCompleted(),
                child: Text(
                  'Clear completed',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Find Grocery Store',
              leadingIcon: Icons.store_outlined,
              onPressed: () => _findGroceryStore(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Plan Shopping Route',
              leadingIcon: Icons.route_outlined,
              variant: AppButtonVariant.outlined,
              onPressed: () => context.push('/list/route'),
            ),
          ],
        ),
      ),
    );
  }

  void _findGroceryStore(BuildContext context) {
    final items = ref.read(groceryListProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add items to your list first.',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
      return;
    }
    ref.read(selectedIngredientsProvider.notifier).state = items
        .map((item) => SelectedIngredient(
              name: item.name,
              quantity: item.quantity,
              storeName: item.storeName,
              cost: item.estimatedPrice,
            ))
        .toList();
    context.push('/groceries/match');
  }
}

// ─── List Item Tile ───────────────────────────────────────────────────────────

class _ListItemTile extends StatelessWidget {
  final GroceryListItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ListItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: item.isChecked ? AppColors.neutral100 : AppColors.white,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                _AnimatedCheckbox(isChecked: item.isChecked),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: item.isChecked
                            ? AppTypography.body1.copyWith(
                                color: AppColors.neutral400,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w600,
                              )
                            : AppTypography.body1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        child: Text(item.name),
                      ),
                      Text(item.quantity, style: AppTypography.body2),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Checkbox ────────────────────────────────────────────────────────

class _AnimatedCheckbox extends StatelessWidget {
  final bool isChecked;

  const _AnimatedCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.success : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? AppColors.success : AppColors.border,
          width: 1.5,
        ),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 14, color: AppColors.white)
          : null,
    );
  }
}

// ─── More Menu Sheet ──────────────────────────────────────────────────────────

class _MoreMenuSheet extends StatelessWidget {
  final VoidCallback onClearCompleted;
  final VoidCallback onClearAll;

  const _MoreMenuSheet({
    required this.onClearCompleted,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
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
            leading: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.neutral600,
            ),
            title: Text('Clear completed items', style: AppTypography.body1),
            onTap: onClearCompleted,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.error,
            ),
            title: Text(
              'Clear all items',
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
        id: 'sl_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        quantity:
            _quantityCtrl.text.trim().isEmpty ? '1' : _quantityCtrl.text.trim(),
        storeName: _storeCtrl.text.trim(),
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
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _FieldLabel('Store (optional)'),
          const SizedBox(height: AppSpacing.xs),
          _SheetField(
            controller: _storeCtrl,
            hint: 'e.g. Jaya Grocer',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
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
