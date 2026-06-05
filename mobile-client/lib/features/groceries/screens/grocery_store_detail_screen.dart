import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';

class GroceryStoreDetailScreen extends StatefulWidget {
  final String storeId;

  const GroceryStoreDetailScreen({super.key, required this.storeId});

  @override
  State<GroceryStoreDetailScreen> createState() =>
      _GroceryStoreDetailScreenState();
}

class _GroceryStoreDetailScreenState extends State<GroceryStoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  static const _categories = [
    'All',
    'Fresh Produce',
    'Pantry',
    'Dairy',
    'Frozen',
  ];

  static const _items = [
    _StoreItem(
      'Fresh Spinach',
      '200 g',
      'RM 2.50',
      _StockLevel.inStock,
      true,
    ),
    _StoreItem('Eggs', '6 pcs', 'RM 4.20', _StockLevel.inStock, true),
    _StoreItem('Soy Sauce', '150 ml', 'RM 1.80', _StockLevel.lowStock, true),
    _StoreItem('Jasmine Rice 5kg', '5 kg', 'RM 18.90', _StockLevel.inStock, false),
    _StoreItem('Oat Milk 1L', '1 L', 'RM 8.50', _StockLevel.outOfStock, false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addToList(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$itemName added to My List',
          style: AppTypography.body1.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStoreHeader(),
                    _buildSearchBar(),
                    _buildCategoryTabs(),
                    _buildItemList(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: Text(
        'Jaya Grocer',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
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
            children: [
              Container(
                width: AppSpacing.avatarMd,
                height: AppSpacing.avatarMd,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  size: 28,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Jaya Grocer',
                            style: AppTypography.headline1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Text(
                            'Claimed',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Supermarket · 0.8 km · Open',
                      style: AppTypography.body2,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '23 Jalan Telawi 3, Bangsar, Kuala Lumpur',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '5 of 6 recipe ingredients available',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: const LinearProgressIndicator(
                    value: 0.83,
                    minHeight: 8,
                    backgroundColor: AppColors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: AppTypography.body1,
          decoration: InputDecoration(
            hintText: 'Search ingredients...',
            hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.neutral400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm + 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral600,
          labelStyle: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTypography.body2,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          dividerColor: AppColors.border,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ],
    );
  }

  Widget _buildItemList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return _IngredientRow(
            item: item,
            isLast: i == _items.length - 1,
            onAdd: () => _addToList(context, item.name),
          );
        }).toList(),
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
          label: 'Add All Recipe Items to List',
          onPressed: () => context.push('/list'),
        ),
      ),
    );
  }
}

// ─── Store Item Model ─────────────────────────────────────────────────────────

enum _StockLevel { inStock, lowStock, outOfStock }

class _StoreItem {
  final String name;
  final String unit;
  final String price;
  final _StockLevel stock;
  final bool isFromRecipe;

  const _StoreItem(
    this.name,
    this.unit,
    this.price,
    this.stock,
    this.isFromRecipe,
  );
}

// ─── Ingredient Row ───────────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final _StoreItem item;
  final bool isLast;
  final VoidCallback onAdd;

  const _IngredientRow({
    required this.item,
    required this.isLast,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = item.stock == _StockLevel.outOfStock;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: item.isFromRecipe ? AppColors.background : AppColors.white,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.radiusLg),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(item.unit, style: AppTypography.body2),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            item.price,
            style: AppTypography.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StockBadge(stock: item.stock),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: isOutOfStock ? null : onAdd,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isOutOfStock ? AppColors.neutral200 : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: isOutOfStock ? AppColors.neutral400 : AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stock Badge ──────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  final _StockLevel stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (stock) {
      _StockLevel.inStock => ('In Stock', AppColors.successLight, AppColors.success),
      _StockLevel.lowStock => ('Low Stock', AppColors.warningLight, AppColors.warning),
      _StockLevel.outOfStock => ('Out of Stock', AppColors.errorLight, AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: fg),
      ),
    );
  }
}
