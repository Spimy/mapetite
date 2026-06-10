import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/widgets/location_sheet.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../models/mocks/restaurant_mocks.dart';
import '../models/restaurant_model.dart';

class RestaurantListingScreen extends StatefulWidget {
  const RestaurantListingScreen({super.key});

  @override
  State<RestaurantListingScreen> createState() =>
      _RestaurantListingScreenState();
}

enum _DineInQuickFilter { halal, openNow, vegan, bestValue, nearest }

class _RestaurantListingScreenState extends State<RestaurantListingScreen> {
  final Set<_DineInQuickFilter> _quickFilters = {};
  String _searchQuery = '';
  final _searchController = TextEditingController();
  _RestaurantFilters _filters = const _RestaurantFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantModel> get _restaurants {
    var list = RestaurantMocks.nearbyRestaurants;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.cuisineType.toLowerCase().contains(q))
          .toList();
    }

    // Quick chips
    for (final f in _quickFilters) {
      switch (f) {
        case _DineInQuickFilter.halal:
          list = list.where((r) => r.dietaryTags.contains('Halal')).toList();
        case _DineInQuickFilter.openNow:
          list = list.where((r) => r.isOpen).toList();
        case _DineInQuickFilter.vegan:
          list = list.where((r) => r.dietaryTags.contains('Vegan')).toList();
        case _DineInQuickFilter.bestValue:
          list = list.where((r) => r.pricingBracket == PricingBracket.budget).toList();
        case _DineInQuickFilter.nearest:
          list = list.where((r) => r.distanceKm <= 1.0).toList();
      }
    }

    // Full filter sheet filters
    if (_filters.cuisines.isNotEmpty) {
      list = list.where((r) => _filters.cuisines.contains(r.cuisineType)).toList();
    }
    for (final d in _filters.dietary) {
      list = list.where((r) => r.dietaryTags.contains(d)).toList();
    }
    if (_filters.underThirtyMinWalk) {
      list = list.where((r) => r.walkMinutes <= 30).toList();
    }
    if (_filters.priceRange != null) {
      list = list.where((r) => r.pricingBracket == _filters.priceRange).toList();
    }

    return list;
  }

  int get _totalActiveFilterCount => _quickFilters.length + _filters.activeCount;

  void _toggleQuickFilter(_DineInQuickFilter f) {
    setState(() {
      if (_quickFilters.contains(f)) {
        _quickFilters.remove(f);
      } else {
        _quickFilters.add(f);
      }
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RestaurantFilterSheet(
        initialFilters: _filters,
        onApply: (f) => setState(() => _filters = f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = _restaurants;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: restaurants.isEmpty
          ? _buildEmptyBody(context)
          : _buildFeedBody(context, restaurants),
    );
  }

  Widget _buildFeedBody(BuildContext context, List<RestaurantModel> restaurants) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < restaurants.length - 1 ? AppSpacing.lg : 0,
                  ),
                  child: _RestaurantCard(
                    restaurant: restaurants[index],
                    onTap: () =>
                        context.push('/restaurants/${restaurants[index].id}'),
                  ),
                );
              },
              childCount: restaurants.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTypography.body1,
        decoration: InputDecoration(
          hintText: 'Search restaurants or cuisine...',
          hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.neutral400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : _FilterIconButton(
                  count: _totalActiveFilterCount,
                  onTap: _openFilterSheet,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const chips = [
      (_DineInQuickFilter.halal,     null,                        'Halal'),
      (_DineInQuickFilter.openNow,   Icons.access_time_outlined,  'Open Now'),
      (_DineInQuickFilter.vegan,     Icons.eco,                   'Vegan'),
      (_DineInQuickFilter.bestValue, Icons.savings_outlined,      'Best Value'),
      (_DineInQuickFilter.nearest,   Icons.near_me_outlined,      'Nearby < 1km'),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: chips.map((def) {
          final (filter, icon, label) = def;
          final isActive = _quickFilters.contains(filter);
          final iconColor = isActive ? AppColors.white : AppColors.neutral600;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => _toggleQuickFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter == _DineInQuickFilter.halal)
                      SvgPicture.asset(
                        'assets/icons/dietary/halal-icon.svg',
                        width: 13,
                        height: 13,
                        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      )
                    else if (icon != null)
                      Icon(icon, size: 13, color: iconColor),
                    const SizedBox(width: 4),
                    Text(label,
                        style: AppTypography.label.copyWith(color: iconColor)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: AppSpacing.appBarHeight,
      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        tooltip: 'Back',
      ),
      title: Text(
        'Dine-In',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _LocationPill(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.avatarLg,
              height: AppSpacing.avatarLg,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No restaurants found',
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your search or filters.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Clear Filters',
              variant: AppButtonVariant.outlined,
              isFullWidth: false,
              onPressed: () => setState(() {
                _quickFilters.clear();
                _filters = const _RestaurantFilters();
                _searchController.clear();
                _searchQuery = '';
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Icon Button (with badge) ──────────────────────────────────────────

class _FilterIconButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FilterIconButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: count > 0 ? AppColors.primary : AppColors.neutral400,
            ),
            if (count > 0)
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
                      '$count',
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
    );
  }
}

// ── Location Pill ─────────────────────────────────────────────────────────────

class _LocationPill extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(locationCityProvider);
    return GestureDetector(
      onTap: () => showLocationSheet(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  city,
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Restaurant Card ───────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: AppSpacing.cardImageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          restaurant.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: restaurant.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.neutral100),
                  errorWidget: (_, _, _) => const _ImagePlaceholder(),
                )
              : const _ImagePlaceholder(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC1F2937)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          if (restaurant.dietaryTags.isNotEmpty)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Row(
                children: restaurant.dietaryTags
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: switch (tag) {
                          'Halal' => const DietaryChip.halal(),
                          'Vegan' => const DietaryChip.vegan(),
                          'Vegetarian' => const DietaryChip.vegetarian(),
                          _ => DietaryChip.allergen(tag),
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _PricingOverlayBadge(bracket: restaurant.pricingBracket),
          ),
          Positioned(
            bottom: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    restaurant.name,
                    style: AppTypography.headline2
                        .copyWith(color: AppColors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 12,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${restaurant.distanceKm}km',
                        style: AppTypography.body2
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xxs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  restaurant.cuisineType,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral700),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.schedule, size: 14, color: AppColors.neutral600),
              const SizedBox(width: 2),
              Text(
                '${restaurant.walkMinutes} min walk',
                style: AppTypography.body2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.thumb_up, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    restaurant.recommendationReason,
                    style: AppTypography.body2
                        .copyWith(color: AppColors.neutral700),
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

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.neutral100,
      child: Center(
        child: Icon(Icons.restaurant, size: 40, color: AppColors.neutral400),
      ),
    );
  }
}


// ── Restaurant Filter Data ────────────────────────────────────────────────────

class _RestaurantFilters {
  final Set<String> cuisines;
  final Set<String> dietary;
  final bool underThirtyMinWalk;
  final PricingBracket? priceRange;
  final Set<String> allergenFree;

  const _RestaurantFilters({
    this.cuisines = const {},
    this.dietary = const {},
    this.underThirtyMinWalk = false,
    this.priceRange,
    this.allergenFree = const {},
  });

  int get activeCount =>
      cuisines.length +
      dietary.length +
      (underThirtyMinWalk ? 1 : 0) +
      (priceRange != null ? 1 : 0) +
      allergenFree.length;
}

// ── Restaurant Filter Sheet ───────────────────────────────────────────────────

class _RestaurantFilterSheet extends StatefulWidget {
  final _RestaurantFilters initialFilters;
  final ValueChanged<_RestaurantFilters> onApply;

  const _RestaurantFilterSheet({
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<_RestaurantFilterSheet> createState() => _RestaurantFilterSheetState();
}

class _RestaurantFilterSheetState extends State<_RestaurantFilterSheet> {
  late Set<String> _cuisines;
  late Set<String> _dietary;
  late bool _underThirtyMin;
  late PricingBracket? _priceRange;
  late Set<String> _allergenFree;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _cuisines = Set.from(f.cuisines);
    _dietary = Set.from(f.dietary);
    _underThirtyMin = f.underThirtyMinWalk;
    _priceRange = f.priceRange;
    _allergenFree = Set.from(f.allergenFree);
  }

  bool get _hasActive =>
      _cuisines.isNotEmpty ||
      _dietary.isNotEmpty ||
      _underThirtyMin ||
      _priceRange != null ||
      _allergenFree.isNotEmpty;

  void _clearAll() => setState(() {
        _cuisines.clear();
        _dietary.clear();
        _underThirtyMin = false;
        _priceRange = null;
        _allergenFree.clear();
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Restaurants', style: AppTypography.headline2),
                      if (_hasActive)
                        GestureDetector(
                          onTap: _clearAll,
                          child: Text('Clear all',
                              style: AppTypography.body2.copyWith(color: AppColors.primary)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuisine
                    Text('Cuisine', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _CuisineIconGrid(
                      active: _cuisines,
                      onToggle: (c) => setState(() {
                        if (_cuisines.contains(c)) _cuisines.remove(c);
                        else _cuisines.add(c);
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Dietary
                    Text('Dietary', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _IconFilterChip(
                          label: 'Halal',
                          isActive: _dietary.contains('Halal'),
                          onToggle: () => setState(() {
                            if (_dietary.contains('Halal')) _dietary.remove('Halal');
                            else _dietary.add('Halal');
                          }),
                          svgAsset: 'assets/icons/dietary/halal-icon.svg',
                        ),
                        _IconFilterChip(
                          label: 'Vegan',
                          isActive: _dietary.contains('Vegan'),
                          onToggle: () => setState(() {
                            if (_dietary.contains('Vegan')) _dietary.remove('Vegan');
                            else _dietary.add('Vegan');
                          }),
                          icon: Icons.eco,
                        ),
                        _IconFilterChip(
                          label: 'Vegetarian',
                          isActive: _dietary.contains('Vegetarian'),
                          onToggle: () => setState(() {
                            if (_dietary.contains('Vegetarian')) _dietary.remove('Vegetarian');
                            else _dietary.add('Vegetarian');
                          }),
                          icon: Icons.spa,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Distance / Time
                    Text('Distance', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _IconFilterChip(
                          label: 'Under 30 min walk',
                          isActive: _underThirtyMin,
                          onToggle: () => setState(() => _underThirtyMin = !_underThirtyMin),
                          icon: Icons.directions_walk,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Price Range
                    Text('Price Range', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Budget RM 5–10  ·  Mid RM 10–20  ·  Premium RM 20+',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _IconFilterChip(
                          label: 'Budget (RM 5–10)',
                          isActive: _priceRange == PricingBracket.budget,
                          onToggle: () => setState(() =>
                              _priceRange = _priceRange == PricingBracket.budget ? null : PricingBracket.budget),
                          icon: Icons.savings_outlined,
                        ),
                        _IconFilterChip(
                          label: 'Mid (RM 10–20)',
                          isActive: _priceRange == PricingBracket.mid,
                          onToggle: () => setState(() =>
                              _priceRange = _priceRange == PricingBracket.mid ? null : PricingBracket.mid),
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        _IconFilterChip(
                          label: 'Premium (RM 20+)',
                          isActive: _priceRange == PricingBracket.premium,
                          onToggle: () => setState(() =>
                              _priceRange = _priceRange == PricingBracket.premium ? null : PricingBracket.premium),
                          icon: Icons.diamond_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Allergen-free
                    Text('Allergen-free (Free from)', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: AppConstants.allergenOptions.map((allergen) {
                        return _IconFilterChip(
                          label: allergen,
                          isActive: _allergenFree.contains(allergen),
                          onToggle: () => setState(() {
                            if (_allergenFree.contains(allergen)) _allergenFree.remove(allergen);
                            else _allergenFree.add(allergen);
                          }),
                          icon: AppChip.allergenIconMap[allergen] ?? Icons.warning_amber,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_RestaurantFilters(
                      cuisines: Set.from(_cuisines),
                      dietary: Set.from(_dietary),
                      underThirtyMinWalk: _underThirtyMin,
                      priceRange: _priceRange,
                      allergenFree: Set.from(_allergenFree),
                    ));
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

// ── Icon Filter Chip ──────────────────────────────────────────────────────────

class _IconFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onToggle;
  final IconData? icon;
  final String? svgAsset;

  const _IconFilterChip({
    required this.label,
    required this.isActive,
    required this.onToggle,
    this.icon,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor = isActive ? AppColors.primary : AppColors.neutral600;
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
              SvgPicture.asset(svgAsset!, width: 13, height: 13,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn))
            else if (icon != null)
              Icon(icon, size: 13, color: contentColor),
            const SizedBox(width: 4),
            Text(label,
                style: AppTypography.label.copyWith(
                  color: contentColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Cuisine Icon Grid ─────────────────────────────────────────────────────────

class _CuisineIconGrid extends StatelessWidget {
  final Set<String> active;
  final ValueChanged<String> onToggle;

  const _CuisineIconGrid({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const totalSpacing = (columns - 1) * AppSpacing.sm;
        final chipWidth = (constraints.maxWidth - totalSpacing) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: AppConstants.cuisineCategories.map((cuisine) {
            final isActive = active.contains(cuisine);
            final icon = AppConstants.cuisineIcons[cuisine] ?? Icons.restaurant;
            return GestureDetector(
              onTap: () => onToggle(cuisine),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: chipWidth,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                  horizontal: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryLight : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 22,
                        color: isActive ? AppColors.primary : AppColors.neutral600),
                    const SizedBox(height: AppSpacing.xs),
                    Text(cuisine,
                        style: AppTypography.caption.copyWith(
                          color: isActive ? AppColors.primary : AppColors.neutral600,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Pricing Overlay Badge ─────────────────────────────────────────────────────

class _PricingOverlayBadge extends StatelessWidget {
  final PricingBracket bracket;

  const _PricingOverlayBadge({required this.bracket});

  String get _label => switch (bracket) {
        PricingBracket.budget => 'RM 5–10',
        PricingBracket.mid => 'RM 10–20',
        PricingBracket.premium => 'RM 20+',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        _label,
        style: AppTypography.label.copyWith(color: AppColors.neutral),
      ),
    );
  }
}
