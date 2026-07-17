import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/providers/store_providers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/food_card.dart';
import '../models/mocks/home_feed_mocks.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _ExploreFilterState {
  final Set<String> categories;
  final Set<String> dietary;

  const _ExploreFilterState({
    this.categories = const {},
    this.dietary = const {},
  });

  int get activeCount => categories.length + dietary.length;

  _ExploreFilterState copyWith({
    Set<String>? categories,
    Set<String>? dietary,
  }) {
    return _ExploreFilterState(
      categories: categories ?? this.categories,
      dietary: dietary ?? this.dietary,
    );
  }
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
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

  // ── Filter helpers ────────────────────────────────────────────────────────

  bool get _showAll => _filterState.categories.isEmpty;
  bool get _showRestaurants =>
      _showAll || _filterState.categories.contains('Restaurants');
  bool get _showRecipes =>
      _showAll || _filterState.categories.contains('Recipes');
  bool get _showGroceries =>
      _showAll || _filterState.categories.contains('Groceries');

  List<StoreModel> _filteredVenues(List<StoreModel> restaurants) {
    var venues = restaurants;
    final dietary = _filterState.dietary;
    if (dietary.contains('Halal')) {
      venues = venues.where((v) => v.dietaryTags.contains('Halal')).toList();
    }
    if (dietary.contains('Vegan')) {
      venues = venues.where((v) => v.dietaryTags.contains('Vegan')).toList();
    }
    if (dietary.contains('Vegetarian')) {
      venues = venues
          .where(
            (v) =>
                v.dietaryTags.contains('Vegan') ||
                v.dietaryTags.contains('Halal'),
          )
          .toList();
    }
    return venues;
  }

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

  List<StoreModel> _filteredResults(
    List<StoreModel> restaurants,
    List<StoreModel> groceries,
  ) {
    final q = _searchQuery.toLowerCase();
    final combined = [...restaurants, ...groceries];
    final matched = combined
        .where(
          (s) =>
              s.businessName.toLowerCase().contains(q) ||
              (s.category?.toLowerCase().contains(q) ?? false),
        )
        .toList();

    return switch (_tabs[_activeTab]) {
      'Restaurants' =>
        matched.where((s) => s.merchantType == StoreType.restaurant).toList(),
      'Groceries' =>
        matched.where((s) => s.merchantType == StoreType.grocery).toList(),
      // 'Recipes' pill: out of scope — leaves results unfiltered, matching
      // its pre-existing (cosmetic-only) behaviour.
      _ => matched,
    };
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider).valueOrNull;
    final lat = location?.latitude ?? 3.0731;
    final lng = location?.longitude ?? 101.6069;
    final restaurantsAsync = ref.watch(
      nearbyStoresProvider(
        NearbyStoresQuery(
          lat: lat,
          lng: lng,
          radiusKm: 20,
          type: StoreType.restaurant,
        ),
      ),
    );
    final groceriesAsync = ref.watch(
      nearbyStoresProvider(
        NearbyStoresQuery(
          lat: lat,
          lng: lng,
          radiusKm: 20,
          type: StoreType.grocery,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // "Explore" display heading — scrolls away
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxxl, bottom: 0),
                child: Center(
                  child: Text(
                    'Explore',
                    style: AppTypography.display.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
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

            // Content: discovery sections or search results, gated on both
            // the restaurant and grocery fetches resolving.
            ...restaurantsAsync.when(
              loading: () => _buildLoadingSlivers(),
              error: (_, _) => _buildErrorSlivers(),
              data: (restaurants) => groceriesAsync.when(
                loading: () => _buildLoadingSlivers(),
                error: (_, _) => _buildErrorSlivers(),
                data: (groceries) => _isSearching
                    ? _buildSearchResultsSections(restaurants, groceries)
                    : _buildDiscoverySections(restaurants, groceries),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading / error states ───────────────────────────────────────────────

  List<Widget> _buildLoadingSlivers() {
    return const [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ];
  }

  List<Widget> _buildErrorSlivers() {
    return [
      const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          description: 'Unable to load nearby stores. Please try again.',
        ),
      ),
    ];
  }

  // ─── Discovery sections (empty search) ───────────────────────────────────────

  List<Widget> _buildDiscoverySections(
    List<StoreModel> restaurants,
    List<StoreModel> groceries,
  ) {
    return [
      // Section 1: Browse by Category (always visible)
      SliverToBoxAdapter(child: _buildCategorySection()),

      // Section 2: Near You Right Now (filtered)
      if (_showRestaurants)
        SliverToBoxAdapter(
          child: _buildNearYouSection(_filteredVenues(restaurants)),
        ),

      // Section 3: Recipes to Try (filtered)
      if (_showRecipes) SliverToBoxAdapter(child: _buildRecipesSection()),

      // Section 4: Grocery Stores (filtered)
      if (_showGroceries)
        SliverToBoxAdapter(child: _buildGrocerySection(groceries)),

      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
    ];
  }

  // ─── Search active sections ───────────────────────────────────────────────────

  List<Widget> _buildSearchResultsSections(
    List<StoreModel> restaurants,
    List<StoreModel> groceries,
  ) {
    return [
      SliverToBoxAdapter(child: _buildTabFilterRow()),
      SliverToBoxAdapter(child: _buildResultsList(restaurants, groceries)),
    ];
  }

  // ─── Section 1: Near You Right Now ───────────────────────────────────────────

  Widget _buildNearYouSection(List<StoreModel> filteredRestaurants) {
    // Teaser length matches the section's original mock data count.
    final venues = filteredRestaurants.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Near You Right Now',
                style: AppTypography.headline2.copyWith(
                  color: AppColors.neutral,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/restaurants'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        if (venues.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Text(
              'No restaurants match your filters.',
              style: AppTypography.body2.copyWith(color: AppColors.neutral400),
            ),
          )
        else
          SizedBox(
            height: 244,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: venues.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) => _NearbyVenueCard(
                venue: venues[i],
                onTap: () =>
                    context.push('${AppRoutes.restaurants}/${venues[i].id}'),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Section 2: Browse by Category ──────────────────────────────────────────

  Widget _buildCategorySection() {
    const row1 = [
      _CategoryDef(
        '🍛',
        'Mamak',
        Color(0xFFFFF3E0),
        Color(0xFFFFCC80),
        '/dine-in?cuisine=mamak',
      ),
      _CategoryDef(
        '🥗',
        'Healthy',
        Color(0xFFE8F5E9),
        Color(0xFFA5D6A7),
        '/dine-in?cuisine=healthy',
      ),
      _CategoryDef(
        '🥐',
        'Bakery',
        Color(0xFFFFFDE7),
        Color(0xFFFFE082),
        '/dine-in?cuisine=bakery',
      ),
      _CategoryDef(
        '🌶️',
        'Spicy',
        Color(0xFFFFEBEE),
        Color(0xFFEF9A9A),
        '/dine-in?cuisine=spicy',
      ),
    ];
    const row2 = [
      _CategoryDef(
        '🍣',
        'Japanese',
        Color(0xFFE0F7FA),
        Color(0xFF80DEEA),
        '/dine-in?cuisine=japanese',
      ),
      _CategoryDef(
        '🐟',
        'Seafood',
        Color(0xFFE3F2FD),
        Color(0xFF90CAF9),
        '/dine-in?cuisine=seafood',
      ),
      _CategoryDef(
        '☕',
        'Cafe',
        Color(0xFFF3E5F5),
        Color(0xFFCE93D8),
        '/dine-in?cuisine=cafe',
      ),
      _CategoryDef(
        '🛒',
        'Groceries',
        AppColors.secondaryLight,
        AppColors.secondaryLight,
        '/groceries',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.md,
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
                  children: row1
                      .map(
                        (def) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _CategoryCard(
                            def: def,
                            onTap: () => context.push(def.route),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: row2
                      .map(
                        (def) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _CategoryCard(
                            def: def,
                            onTap: () => context.push(def.route),
                          ),
                        ),
                      )
                      .toList(),
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
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipes to Try',
                style: AppTypography.headline2.copyWith(
                  color: AppColors.neutral,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/cook-in'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Browse all',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 224,
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

  Widget _buildGrocerySection(List<StoreModel> groceries) {
    // Teaser length matches the section's original mock data count.
    final stores = groceries.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grocery Stores Near You',
                style: AppTypography.headline2.copyWith(
                  color: AppColors.neutral,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/groceries'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
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
                  onTap: () =>
                      context.push('${AppRoutes.groceries}/${stores[i].id}'),
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
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
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
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildResultsList(
    List<StoreModel> restaurants,
    List<StoreModel> groceries,
  ) {
    final results = _filteredResults(restaurants, groceries);
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
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        children: results
            .map(
              (store) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SearchResultCard(
                  store: store,
                  onTap: () => context.push(
                    store.merchantType == StoreType.grocery
                        ? '${AppRoutes.groceries}/${store.id}'
                        : '${AppRoutes.restaurants}/${store.id}',
                  ),
                ),
              ),
            )
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
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
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
  final StoreModel venue;
  final VoidCallback onTap;

  const _NearbyVenueCard({required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 32,
                                    color: AppColors.neutral400,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.neutral100,
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 32,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ),
                      if (venue.dietaryTags.contains('Halal'))
                        const Positioned(
                          top: 8,
                          left: 8,
                          child: DietaryChip.halal(),
                        )
                      else if (venue.dietaryTags.contains('Vegan'))
                        const Positioned(
                          top: 8,
                          left: 8,
                          child: DietaryChip.vegan(),
                        ),
                      if (venue.openStatus.isOpen)
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
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
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
                      Text(
                        venue.businessName,
                        style: AppTypography.headline3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (venue.category != null)
                        Text(
                          venue.category!,
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
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
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
                                  '${(venue.distanceKm ?? 0).toStringAsFixed(1)} km',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
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
    this.emoji,
    this.label,
    this.bgColor,
    this.borderColor,
    this.route,
  );
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
  final StoreModel store;
  final bool showDivider;
  final VoidCallback onTap;

  const _GroceryRow({
    required this.store,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    store.businessName,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.neutral,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    store.category != null
                        ? '${store.category} · ${(store.distanceKm ?? 0).toStringAsFixed(1)}km'
                        : '${(store.distanceKm ?? 0).toStringAsFixed(1)}km',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (store.openStatus.isOpen)
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
      ),
    );
  }
}

// ─── Search Result Card ───────────────────────────────────────────────────────

class _SearchResultCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _SearchResultCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGrocery = store.merchantType == StoreType.grocery;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Icon(
                isGrocery ? Icons.local_grocery_store : Icons.restaurant,
                size: 28,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.businessName,
                    style: AppTypography.headline3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  if (store.category != null)
                    Text(
                      store.category!,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(store.distanceKm ?? 0).toStringAsFixed(1)} km',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (store.dietaryTags.contains('Halal'))
                        const DietaryChip.halal()
                      else if (store.dietaryTags.contains('Vegan'))
                        const DietaryChip.vegan(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Explore Filter Sheet ─────────────────────────────────────────────────────
// Matches recipe_listing_screen _FilterBottomSheet exactly:
// icon-grid for Category, _IconFilterChip pills for Dietary + Price.

class _ExploreFilterSheet extends StatefulWidget {
  final _ExploreFilterState filterState;
  final ValueChanged<_ExploreFilterState> onApply;

  const _ExploreFilterSheet({required this.filterState, required this.onApply});

  @override
  State<_ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<_ExploreFilterSheet> {
  late Set<String> _selectedCategories;
  late Set<String> _selectedDietary;

  // Category icon-grid definitions — same structure as _CuisineIconGrid
  static const _categoryItems = [
    (Icons.restaurant, 'Restaurants'),
    (Icons.menu_book_outlined, 'Recipes'),
    (Icons.local_grocery_store_outlined, 'Groceries'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.filterState.categories);
    _selectedDietary = Set.from(widget.filterState.dietary);
  }

  bool get _hasFilters =>
      _selectedCategories.isNotEmpty || _selectedDietary.isNotEmpty;

  void _toggleSet(Set<String> set, String value) => setState(() {
    set.contains(value) ? set.remove(value) : set.add(value);
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
            // ── Handle + header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
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
                            _selectedCategories.clear();
                            _selectedDietary.clear();
                          }),
                          child: Text(
                            'Clear all',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category — icon grid (matches _CuisineIconGrid) ──────
                    Text(
                      'Category',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const columns = 3;
                        const totalSpacing = (columns - 1) * AppSpacing.sm;
                        final tileW =
                            (constraints.maxWidth - totalSpacing) / columns;
                        return Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _categoryItems.map((item) {
                            final (icon, label) = item;
                            final isActive = _selectedCategories.contains(
                              label,
                            );
                            return GestureDetector(
                              onTap: () =>
                                  _toggleSet(_selectedCategories, label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: tileW,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm + 2,
                                  horizontal: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryLight
                                      : AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isActive ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 22,
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.neutral600,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      label,
                                      style: AppTypography.caption.copyWith(
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.neutral600,
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Dietary — icon+text pills (matches _IconFilterChip) ──
                    Text(
                      'Dietary',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _ExploreIconChip(
                          label: 'Halal',
                          svgAsset: 'assets/icons/dietary/halal-icon.svg',
                          isActive: _selectedDietary.contains('Halal'),
                          onToggle: () => _toggleSet(_selectedDietary, 'Halal'),
                        ),
                        _ExploreIconChip(
                          label: 'Vegan',
                          icon: Icons.eco,
                          isActive: _selectedDietary.contains('Vegan'),
                          onToggle: () => _toggleSet(_selectedDietary, 'Vegan'),
                        ),
                        _ExploreIconChip(
                          label: 'Vegetarian',
                          icon: Icons.spa,
                          isActive: _selectedDietary.contains('Vegetarian'),
                          onToggle: () =>
                              _toggleSet(_selectedDietary, 'Vegetarian'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // ── Apply button ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _ExploreFilterState(
                        categories: Set.from(_selectedCategories),
                        dietary: Set.from(_selectedDietary),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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

// ─── Icon+label pill chip — identical styling to recipe _IconFilterChip ────────

class _ExploreIconChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onToggle;
  final IconData? icon;
  final String? svgAsset;

  const _ExploreIconChip({
    required this.label,
    required this.isActive,
    required this.onToggle,
    this.icon,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.neutral600;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
