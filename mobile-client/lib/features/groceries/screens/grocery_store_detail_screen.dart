import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/store_item_model.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/store_providers.dart';
import '../../../shared/utils/directions_util.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';

class GroceryStoreDetailScreen extends ConsumerStatefulWidget {
  final String storeId;

  const GroceryStoreDetailScreen({super.key, required this.storeId});

  @override
  ConsumerState<GroceryStoreDetailScreen> createState() =>
      _GroceryStoreDetailScreenState();
}

class _GroceryStoreDetailScreenState
    extends ConsumerState<GroceryStoreDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _tabController?.dispose();
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

  List<String> _categoryTabs(List<StoreItemModel> items) => [
        'All',
        ...items.map((i) => i.category).toSet().toList()..sort(),
      ];

  List<StoreItemModel> _filteredItems(
    List<StoreItemModel> items,
    List<String> tabs,
    int activeIndex,
  ) {
    final tab = tabs[activeIndex];
    if (tab == 'All') return items;
    return items.where((i) => i.category == tab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeDetailProvider(widget.storeId));
    final itemsAsync = ref.watch(storeItemsProvider(widget.storeId));

    return storeAsync.when(
      loading: () => _buildLoadingScaffold(),
      error: (_, _) => _buildErrorScaffold(
        description: 'Unable to load this store. Please try again.',
        onRetry: () {
          ref.invalidate(storeDetailProvider(widget.storeId));
          ref.invalidate(storeItemsProvider(widget.storeId));
        },
      ),
      data: (store) => itemsAsync.when(
        loading: () => _buildLoadingScaffold(),
        error: (_, _) => _buildErrorScaffold(
          description: 'Unable to load the products. Please try again.',
          onRetry: () => ref.invalidate(storeItemsProvider(widget.storeId)),
        ),
        data: (items) => _buildDataScaffold(context, store, items),
      ),
    );
  }

  Scaffold _buildLoadingScaffold() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoader(
              width: double.infinity,
              height: 160,
              borderRadius: AppSpacing.radiusLg,
            ),
            SizedBox(height: AppSpacing.lg),
            ShimmerLoader(width: 200, height: 20),
            SizedBox(height: AppSpacing.sm),
            ShimmerLoader(width: 140, height: 14),
            SizedBox(height: AppSpacing.xl),
            CardShimmer(height: 80),
            SizedBox(height: AppSpacing.md),
            CardShimmer(height: 80),
          ],
        ),
      ),
    );
  }

  Scaffold _buildErrorScaffold({
    required String description,
    required VoidCallback onRetry,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppEmptyState(
        icon: Icons.error_outline,
        title: 'Something went wrong',
        description: description,
        ctaLabel: 'Retry',
        onCta: onRetry,
      ),
    );
  }

  Scaffold _buildDataScaffold(
    BuildContext context,
    StoreModel store,
    List<StoreItemModel> items,
  ) {
    final tabs = _categoryTabs(items);
    if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }
    final activeIndex = _tabController!.index.clamp(0, tabs.length - 1);
    final filtered = _filteredItems(items, tabs, activeIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, store),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStoreHeader(store),
                    _buildSearchBar(),
                    _buildCategoryTabs(tabs),
                    _buildItemList(context, filtered),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(context, store),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, StoreModel store) {
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
        store.businessName,
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildStoreHeader(StoreModel store) {
    final subtitleParts = <String>[
      if (store.category != null) store.category!,
      store.openStatus.isOpen ? 'Open' : 'Closed',
    ];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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
                Text(store.businessName, style: AppTypography.headline1),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitleParts.join(' · '), style: AppTypography.body2),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  store.streetAddress,
                  style: AppTypography.body2.copyWith(color: AppColors.neutral600),
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

  Widget _buildCategoryTabs(List<String> tabs) {
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
          onTap: (_) => setState(() {}),
          tabs: tabs.map((c) => Tab(text: c)).toList(),
        ),
      ],
    );
  }

  Widget _buildItemList(BuildContext context, List<StoreItemModel> items) {
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
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return _IngredientRow(
            item: item,
            isLast: i == items.length - 1,
            onAdd: () => _addToList(context, item.name),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, StoreModel store) {
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
          label: 'Get Directions',
          leadingIcon: Icons.directions,
          onPressed: () => openDirections(context, store),
        ),
      ),
    );
  }
}

// ─── Ingredient Row ───────────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final StoreItemModel item;
  final bool isLast;
  final VoidCallback onAdd;

  const _IngredientRow({
    required this.item,
    required this.isLast,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = item.stockStatus == 'OUT_OF_STOCK';

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
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
                if (item.unitSize != null)
                  Text(item.unitSize!, style: AppTypography.body2),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'RM ${item.price.toStringAsFixed(2)}',
            style: AppTypography.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StockBadge(stockStatus: item.stockStatus),
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
  final String stockStatus;

  const _StockBadge({required this.stockStatus});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (stockStatus) {
      'IN_STOCK' => ('In Stock', AppColors.successLight, AppColors.success),
      'LOW_STOCK' => ('Low Stock', AppColors.warningLight, AppColors.warning),
      'OUT_OF_STOCK' => ('Out of Stock', AppColors.errorLight, AppColors.error),
      _ => ('In Stock', AppColors.successLight, AppColors.success),
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
