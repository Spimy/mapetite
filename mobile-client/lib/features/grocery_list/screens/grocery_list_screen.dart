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

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _addItemCtrl = TextEditingController();

  @override
  void dispose() {
    _addItemCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _addItemCtrl.text.trim();
    if (name.isEmpty) return;
    ref.read(groceryListProvider.notifier).addItem(
          GroceryListItem(
            id: 'sl_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            quantity: '1',
            storeName: '',
            estimatedPrice: 0,
          ),
        );
    _addItemCtrl.clear();
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
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.neutral),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _addItemCtrl,
              style: AppTypography.body1,
              onSubmitted: (_) => _addItem(),
              decoration: InputDecoration(
                hintText: 'Add an item...',
                hintStyle: AppTypography.body1.copyWith(
                  color: AppColors.neutral400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 80,
          height: 44,
          child: ElevatedButton(
            onPressed: _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
            child: Text('Add', style: AppTypography.button),
          ),
        ),
      ],
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
        child: AppButton(
          label: 'Plan Shopping Route',
          leadingIcon: Icons.route_outlined,
          onPressed: () => context.push('/list/route'),
        ),
      ),
    );
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

  const _MoreMenuSheet({required this.onClearCompleted});

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
        ],
      ),
    );
  }
}
