import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../models/mocks/restaurant_mocks.dart';
import '../models/restaurant_model.dart';

class RestaurantListingScreen extends StatefulWidget {
  const RestaurantListingScreen({super.key});

  @override
  State<RestaurantListingScreen> createState() =>
      _RestaurantListingScreenState();
}

enum _DineInFilter { halal, openNow, vegan, bestValue, nearest }

class _RestaurantListingScreenState extends State<RestaurantListingScreen> {
  int _activeSortIndex = 0;
  final List<String> _sortOptions = ['Best Match', 'Nearest', 'Budget', 'Cuisine'];
  Set<String> _activeCuisines = {};
  final Set<_DineInFilter> _activeFilters = {};
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantModel> get _restaurants {
    var list = RestaurantMocks.nearbyRestaurants;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.cuisineType.toLowerCase().contains(q))
          .toList();
    }

    // Cuisine filter
    if (_activeCuisines.isNotEmpty) {
      list = list.where((r) => _activeCuisines.contains(r.cuisineType)).toList();
    }

    // Quick filters
    for (final filter in _activeFilters) {
      switch (filter) {
        case _DineInFilter.halal:
          list = list.where((r) => r.dietaryTags.contains('Halal')).toList();
        case _DineInFilter.openNow:
          list = list.where((r) => r.isOpen).toList();
        case _DineInFilter.vegan:
          list = list.where((r) => r.dietaryTags.contains('Vegan')).toList();
        case _DineInFilter.bestValue:
          list = list.where((r) => r.pricingBracket == PricingBracket.budget).toList();
        case _DineInFilter.nearest:
          list = list.where((r) => r.distanceKm <= 1.0).toList();
      }
    }

    return list;
  }

  void _toggleFilter(_DineInFilter f) {
    setState(() {
      if (_activeFilters.contains(f)) {
        _activeFilters.remove(f);
      } else {
        _activeFilters.add(f);
      }
    });
  }

  void _openCuisineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CuisineFilterSheet(
        activeCuisines: _activeCuisines,
        onApply: (selected) => setState(() => _activeCuisines = selected),
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
              : null,
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
      (_DineInFilter.halal,   Icons.check_circle_outline, 'Halal'),
      (_DineInFilter.openNow, Icons.access_time_outlined, 'Open Now'),
      (_DineInFilter.vegan,   Icons.eco,                  'Vegan'),
      (_DineInFilter.bestValue, Icons.savings_outlined,   'Best Value'),
      (_DineInFilter.nearest, Icons.near_me_outlined,     'Nearby < 1km'),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: chips.map((def) {
          final (filter, icon, label) = def;
          final isActive = _activeFilters.contains(filter);
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => _toggleFilter(filter),
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
                    Icon(
                      icon,
                      size: 13,
                      color: isActive ? AppColors.white : AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: isActive ? AppColors.white : AppColors.neutral600,
                      ),
                    ),
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
        preferredSize: const Size.fromHeight(52),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: _SortPillRow(
            options: _sortOptions,
            activeIndex: _activeSortIndex,
            activeCuisineCount: _activeCuisines.length,
            onChanged: (i) {
              if (_sortOptions[i] == 'Cuisine') {
                _openCuisineSheet();
              } else {
                setState(() => _activeSortIndex = i);
              }
            },
          ),
        ),
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
              "Try adjusting your search or filters.",
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Clear Filters',
              variant: AppButtonVariant.outlined,
              isFullWidth: false,
              onPressed: () => setState(() {
                _activeFilters.clear();
                _activeCuisines.clear();
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

// ── Sort Pill Row ─────────────────────────────────────────────────────────────

class _SortPillRow extends StatelessWidget {
  final List<String> options;
  final int activeIndex;
  final int activeCuisineCount;
  final ValueChanged<int> onChanged;

  const _SortPillRow({
    required this.options,
    required this.activeIndex,
    required this.activeCuisineCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: options.asMap().entries.map((entry) {
          final isActive = entry.key == activeIndex;
          final label = entry.value;
          final isCuisine = label == 'Cuisine';
          return Padding(
            padding: EdgeInsets.only(
              right: entry.key < options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (isActive || (isCuisine && activeCuisineCount > 0))
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: (isActive || (isCuisine && activeCuisineCount > 0))
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTypography.body2.copyWith(
                            color: (isActive || (isCuisine && activeCuisineCount > 0))
                                ? AppColors.white
                                : AppColors.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isCuisine) ...[
                          const SizedBox(width: 2),
                          Icon(
                            Icons.expand_more,
                            size: 14,
                            color: (isActive || activeCuisineCount > 0)
                                ? AppColors.white
                                : AppColors.neutral600,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCuisine && activeCuisineCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$activeCuisineCount',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontSize: 9,
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
        }).toList(),
      ),
    );
  }
}

// ── Location Pill ─────────────────────────────────────────────────────────────

class _LocationPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'Subang Jaya',
            style: AppTypography.body2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.expand_more, size: 14, color: AppColors.primary),
        ],
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
                        child: _DietaryOverlayChip(tag: tag),
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

class _DietaryOverlayChip extends StatelessWidget {
  final String tag;

  const _DietaryOverlayChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.tagHalal,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        tag,
        style: AppTypography.label.copyWith(color: AppColors.white),
      ),
    );
  }
}

// ── Cuisine Filter Sheet ──────────────────────────────────────────────────────

class _CuisineFilterSheet extends StatefulWidget {
  final Set<String> activeCuisines;
  final ValueChanged<Set<String>> onApply;

  const _CuisineFilterSheet({
    required this.activeCuisines,
    required this.onApply,
  });

  @override
  State<_CuisineFilterSheet> createState() => _CuisineFilterSheetState();
}

class _CuisineFilterSheetState extends State<_CuisineFilterSheet> {
  static const _allCuisines = [
    ('🍛', 'Mamak'),
    ('☕', 'Kopitiam'),
    ('🍱', 'Japanese'),
    ('🥘', 'Chinese'),
    ('🍛', 'Indian'),
    ('🍚', 'Malay'),
    ('🍔', 'Western'),
    ('🐟', 'Seafood'),
    ('🥗', 'Vegetarian'),
    ('🍜', 'Korean'),
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.activeCuisines);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter by Cuisine', style: AppTypography.headline2),
                      if (_selected.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _selected.clear()),
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
            const SizedBox(height: AppSpacing.lg),
            // Cuisine grid
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _allCuisines.map((c) {
                    final (emoji, name) = c;
                    final isActive = _selected.contains(name);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isActive) {
                          _selected.remove(name);
                        } else {
                          _selected.add(name);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryLight
                              : AppColors.neutral100,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              name,
                              style: AppTypography.body2.copyWith(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.neutral600,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(Set.from(_selected));
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
