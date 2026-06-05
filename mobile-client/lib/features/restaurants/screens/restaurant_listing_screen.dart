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

class _RestaurantListingScreenState extends State<RestaurantListingScreen> {
  int _activeSortIndex = 0;
  final List<String> _sortOptions = ['Best Match', 'Nearest', 'Budget', 'Cuisine'];

  List<RestaurantModel> get _restaurants => RestaurantMocks.nearbyRestaurants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _restaurants.isEmpty
          ? _buildEmptyBody(context)
          : _buildFeedBody(context),
    );
  }

  Widget _buildFeedBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _restaurants.length - 1 ? AppSpacing.lg : 0,
                  ),
                  child: _RestaurantCard(
                    restaurant: _restaurants[index],
                    onTap: () =>
                        context.push('/restaurants/${_restaurants[index].id}'),
                  ),
                );
              },
              childCount: _restaurants.length,
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
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(),
        ),
      ],
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
        onPressed: () => context.pop(),
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
            onChanged: (i) => setState(() => _activeSortIndex = i),
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
              'No restaurants nearby',
              style: AppTypography.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "We couldn't find restaurants matching your preferences within 2 km. Try adjusting your filters.",
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Adjust Filters',
              variant: AppButtonVariant.outlined,
              isFullWidth: false,
              onPressed: () {},
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
  final ValueChanged<int> onChanged;

  const _SortPillRow({
    required this.options,
    required this.activeIndex,
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
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.body2.copyWith(
                        color: isActive ? AppColors.white : AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isCuisine) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more,
                        size: 14,
                        color: isActive ? AppColors.white : AppColors.neutral600,
                      ),
                    ],
                  ],
                ),
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
                colors: [Colors.transparent, Color(0xCC000000)],
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
