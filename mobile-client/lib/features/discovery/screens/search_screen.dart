import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/food_card.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../../restaurants/models/mocks/restaurant_mocks.dart';
import '../../restaurants/models/restaurant_model.dart';
import '../models/home_feed_models.dart';
import '../models/mocks/explore_mocks.dart';
import '../models/mocks/home_feed_mocks.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _ExploreFilterState {
  final Set<String> categories;
  final Set<String> dietary;
  final String? priceRange;

  const _ExploreFilterState({
    this.categories = const {},
    this.dietary = const {},
    this.priceRange,
  });

  int get activeCount =>
      categories.length + dietary.length + (priceRange != null ? 1 : 0);

  _ExploreFilterState copyWith({
    Set<String>? categories,
    Set<String>? dietary,
    String? priceRange,
    bool clearPrice = false,
  }) {
    return _ExploreFilterState(
      categories: categories ?? this.categories,
      dietary: dietary ?? this.dietary,
      priceRange: clearPrice ? null : (priceRange ?? this.priceRange),
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _activeTab = 0;
  _ExploreFilterState _filterState = const _ExploreFilterState();

  static const List<String> _tabs = ['Restaurants', 'Recipes', 'Groceries'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _searchQuery.isNotEmpty;

  void _openExploreFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExploreFilterSheet(
        filterState: _filterState,
        onApply: (updated) => setState(() => _filterState = updated),
      ),
    );
  }

  List<RestaurantModel> get _filteredResults {
    final q = _searchQuery.toLowerCase();
    return RestaurantMocks.nearbyRestaurants
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisineType.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // "Explore" display heading — scrolls away
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.xxxl,
                  bottom: 0,
                ),
                child: Text(
                  'Explore',
                  style: AppTypography.display.copyWith(color: AppColors.neutral),
                ),
              ),
            ),

            // Sticky search bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                searchController: _searchController,
                onFilterTap: _openExploreFilterSheet,
                activeFilterCount: _filterState.activeCount,
              ),
            ),

            // Content: discovery sections or search results
            if (!_isSearching) ..._buildDiscoverySections()
            else ..._buildSearchResultsSections(),
          ],
        ),
      ),
    );
  }

  // ─── Discovery sections (empty search) ───────────────────────────────────────

  List<Widget> _buildDiscoverySections() {
    return [
      // Section 1: Near You Right Now
      SliverToBoxAdapter(child: _buildNearYouSection()),

      // Section 2: Browse by Category
      SliverToBoxAdapter(child: _buildCategorySection()),

      // Section 3: Recipes to Try
      SliverToBoxAdapter(child: _buildRecipesSection()),

      // Section 4: Grocery Stores
      SliverToBoxAdapter(child: _buildGrocerySection()),

      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
    ];
  }

  // ─── Search active sections ───────────────────────────────────────────────────

  List<Widget> _buildSearchResultsSections() {
    return [
      SliverToBoxAdapter(child: _buildTabFilterRow()),
      SliverToBoxAdapter(child: _buildResultsList()),
    ];
  }

  // ─── Section 1: Near You Right Now ───────────────────────────────────────────

  Widget _buildNearYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Near You Right Now',
                style: AppTypography.headline2.copyWith(color: AppColors.neutral),
              ),
              TextButton(
                onPressed: () => context.go('/restaurants'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: AppTypography.body2.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: ExploreMocks.nearbyVenues.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) => _NearbyVenueCard(
              venue: ExploreMocks.nearbyVenues[i],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section 2: Browse by Category ──────────────────────────────────────────

  Widget _buildCategorySection() {
    const row1 = [
      _CategoryDef('🍛', 'Mamak', Color(0xFFFFF3E0), Color(0xFFFFCC80), '/dine-in?cuisine=mamak'),
      _CategoryDef('🥗', 'Healthy', Color(0xFFE8F5E9), Color(0xFFA5D6A7), '/dine-in?cuisine=healthy'),
      _CategoryDef('🥐', 'Bakery', Color(0xFFFFFDE7), Color(0xFFFFE082), '/dine-in?cuisine=bakery'),
      _CategoryDef('🌶️', 'Spicy', Color(0xFFFFEBEE), Color(0xFFEF9A9A), '/dine-in?cuisine=spicy'),
    ];
    const row2 = [
      _CategoryDef('🍣', 'Japanese', Color(0xFFE0F7FA), Color(0xFF80DEEA), '/dine-in?cuisine=japanese'),
      _CategoryDef('🐟', 'Seafood', Color(0xFFE3F2FD), Color(0xFF90CAF9), '/dine-in?cuisine=seafood'),
      _CategoryDef('☕', 'Cafe', Color(0xFFF3E5F5), Color(0xFFCE93D8), '/dine-in?cuisine=cafe'),
      _CategoryDef('🛒', 'Groceries', AppColors.secondaryLight, AppColors.secondaryLight, '/groceries'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md,
          ),
          child: Text(
            'Browse by Category',
            style: AppTypography.headline2.copyWith(color: AppColors.neutral),
          ),
        ),
        SizedBox(
          height: 224,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: row1.map((def) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _CategoryCard(def: def, onTap: () => context.go(def.route)),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: row2.map((def) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _CategoryCard(def: def, onTap: () => context.go(def.route)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section 3: Recipes to Try ──────────────────────────────────────────────

  Widget _buildRecipesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipes to Try',
                style: AppTypography.headline2.copyWith(color: AppColors.neutral),
              ),
              TextButton(
                onPressed: () => context.go('/cook-in'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Browse all',
                  style: AppTypography.body2.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: HomeFeedMocks.cookInRecipes.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) {
              final recipe = HomeFeedMocks.cookInRecipes[i];
              return SizedBox(
                width: 160,
                child: RecipeHorizontalCard(
                  recipe: recipe,
                  onTap: () => context.go('/cook-in'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Section 4: Grocery Stores Near You ──────────────────────────────────────

  Widget _buildGrocerySection() {
    const stores = HomeFeedMocks.nearbyGroceries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grocery Stores Near You',
                style: AppTypography.headline2.copyWith(color: AppColors.neutral),
              ),
              TextButton(
                onPressed: () => context.go('/groceries'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: AppTypography.body2.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(stores.length, (i) {
                return _GroceryRow(
                  store: stores[i],
                  showDivider: i < stores.length - 1,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Search active: tab filter row ───────────────────────────────────────────

  Widget _buildTabFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final isActive = _activeTab == i;
            return Padding(
              padding: EdgeInsets.only(
                right: i < _tabs.length - 1 ? AppSpacing.sm : 0,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: AppTypography.label.copyWith(
                      color: isActive ? AppColors.white : AppColors.neutral,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Search active: results list ─────────────────────────────────────────────

  Widget _buildResultsList() {
    final results = _filteredResults;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: AppEmptyState(
          icon: Icons.search_off,
          title: 'No results for "$_searchQuery"',
          description: 'Try clearing some filters or expanding your search.',
          ctaLabel: 'Clear Search',
          onCta: () => setState(() {
            _searchQuery = '';
            _searchController.clear();
          }),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl,
      ),
      child: Column(
        children: results
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SearchResultCard(restaurant: r),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Sticky Search Bar Delegate ───────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final int activeFilterCount;

  const _SearchBarDelegate({
    required this.searchController,
    required this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) =>
      oldDelegate.activeFilterCount != activeFilterCount;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            const Icon(Icons.search, color: AppColors.neutral400, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: searchController,
                style: AppTypography.body1,
                decoration: InputDecoration(
                  hintText: 'Search restaurants, recipes, grocery stores...',
                  hintStyle: AppTypography.body1.copyWith(
                    color: AppColors.neutral400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Filter button — matches recipe screen _FilterIconButton style
            GestureDetector(
              onTap: onFilterTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: activeFilterCount > 0
                          ? AppColors.primary
                          : AppColors.neutral400,
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$activeFilterCount',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Nearby Venue Card ────────────────────────────────────────────────────────

class _NearbyVenueCard extends StatelessWidget {
  final NearbyVenueSummary venue;

  const _NearbyVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with "Open" badge
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    venue.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: venue.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.neutral100,
                              highlightColor: AppColors.white,
                              child: Container(color: AppColors.neutral100),
                            ),
                            errorWidget: (context, url, err) => Container(
                              color: AppColors.neutral100,
                              child: const Center(
                                child: Icon(Icons.restaurant,
                                    size: 32, color: AppColors.neutral400),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral100,
                            child: const Center(
                              child: Icon(Icons.restaurant,
                                  size: 32, color: AppColors.neutral400),
                            ),
                          ),
                    if (venue.isOpen)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Open',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Card body
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            venue.name,
                            style: AppTypography.headline3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        PricingBadge(
                          bracket: ExploreMocks.pricingBracketFor(venue),
                          customLabel: venue.pricingBracket,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      venue.cuisineType,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${venue.distanceKm.toStringAsFixed(1)} km',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          venue.rating.toStringAsFixed(1),
                          style: AppTypography.label.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryDef {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final String route;

  const _CategoryDef(
      this.emoji, this.label, this.bgColor, this.borderColor, this.route);
}

class _CategoryCard extends StatelessWidget {
  final _CategoryDef def;
  final VoidCallback onTap;

  const _CategoryCard({required this.def, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            color: def.bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: def.borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(def.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                def.label,
                style: AppTypography.label.copyWith(color: AppColors.neutral),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grocery Row ─────────────────────────────────────────────────────────────

class _GroceryRow extends StatelessWidget {
  final GrocerySummary store;
  final bool showDivider;

  const _GroceryRow({required this.store, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_grocery_store_outlined,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  store.name,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${store.type} · ${store.distanceKm.toStringAsFixed(1)}km',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (store.isOpen)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Open',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Search Result Card ───────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const _SearchResultCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.restaurant, size: 28, color: AppColors.neutral400),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: AppTypography.headline3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  restaurant.cuisineType,
                  style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.neutral400),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.distanceKm.toStringAsFixed(1)} km',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (restaurant.dietaryTags.contains('Halal'))
                      const DietaryChip.halal(),
                  ],
                ),
              ],
            ),
          ),
          PricingBadge(bracket: restaurant.pricingBracket),
        ],
      ),
    );
  }
}

// ─── Explore Filter Sheet ─────────────────────────────────────────────────────

class _ExploreFilterSheet extends StatefulWidget {
  final _ExploreFilterState filterState;
  final ValueChanged<_ExploreFilterState> onApply;

  const _ExploreFilterSheet({
    required this.filterState,
    required this.onApply,
  });

  @override
  State<_ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<_ExploreFilterSheet> {
  static const _categories = ['Restaurants', 'Recipes', 'Groceries'];
  static const _dietaryOptions = ['Halal', 'Vegan', 'Vegetarian'];
  static const _priceOptions = [
    ('Budget', 'RM 5–10'),
    ('Mid', 'RM 10–20'),
    ('Premium', 'RM 20+'),
  ];

  late Set<String> _categories2;
  late Set<String> _dietary;
  late String? _priceRange;

  @override
  void initState() {
    super.initState();
    _categories2 = Set.from(widget.filterState.categories);
    _dietary = Set.from(widget.filterState.dietary);
    _priceRange = widget.filterState.priceRange;
  }

  bool get _hasFilters =>
      _categories2.isNotEmpty || _dietary.isNotEmpty || _priceRange != null;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0,
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter', style: AppTypography.headline2),
                      if (_hasFilters)
                        GestureDetector(
                          onTap: () => setState(() {
                            _categories2.clear();
                            _dietary.clear();
                            _priceRange = null;
                          }),
                          child: Text(
                            'Clear all',
                            style: AppTypography.body2
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      'Category',
                      style: AppTypography.headline3
                          .copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _categories.map((cat) {
                        final isActive = _categories2.contains(cat);
                        return _FilterChip(
                          label: cat,
                          isActive: isActive,
                          onTap: () => setState(() {
                            if (isActive) {
                              _categories2.remove(cat);
                            } else {
                              _categories2.add(cat);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Dietary
                    Text(
                      'Dietary',
                      style: AppTypography.headline3
                          .copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _dietaryOptions.map((d) {
                        final isActive = _dietary.contains(d);
                        return _FilterChip(
                          label: d,
                          isActive: isActive,
                          onTap: () => setState(() {
                            if (isActive) {
                              _dietary.remove(d);
                            } else {
                              _dietary.add(d);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Price range
                    Text(
                      'Price Range',
                      style: AppTypography.headline3
                          .copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _priceOptions.map((p) {
                        final (key, label) = p;
                        final isActive = _priceRange == key;
                        return _FilterChip(
                          label: label,
                          isActive: isActive,
                          onTap: () => setState(() {
                            _priceRange = isActive ? null : key;
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _ExploreFilterState(
                        categories: Set.from(_categories2),
                        dietary: Set.from(_dietary),
                        priceRange: _priceRange,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Apply Filters', style: AppTypography.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable filter chip ─────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body2.copyWith(
            color: isActive ? AppColors.primary : AppColors.neutral600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
