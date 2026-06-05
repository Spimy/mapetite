import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../../../shared/widgets/custom_button.dart';
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _restaurants.isEmpty
                  ? _buildEmptyState()
                  : _buildFeed(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: AppSpacing.appBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              tooltip: 'Back',
            ),
          ),
          Text(
            'Dine-In',
            style: AppTypography.headline1.copyWith(color: AppColors.primary),
          ),
          Positioned(
            right: AppSpacing.lg,
            child: _LocationPill(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSortPillRow()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _restaurants.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _RestaurantCard(
                      restaurant: _restaurants[index],
                      onTap: () => context.push(
                        '/restaurants/${_restaurants[index].id}',
                      ),
                    ),
                  );
                }
                // Load-more shimmer after last real card
                return const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  child: CardShimmer(),
                );
              },
              childCount: _restaurants.length + 1,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildCrowdsourcedNote()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  Widget _buildSortPillRow() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: _sortOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isActive = index == _activeSortIndex;
          final label = _sortOptions[index];
          final isCuisine = label == 'Cuisine';
          return GestureDetector(
            onTap: () => setState(() => _activeSortIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: isActive ? AppColors.white : AppColors.neutral600,
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
          );
        },
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

  Widget _buildCrowdsourcedNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 12,
            color: AppColors.neutral400,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Ratings are crowdsourced from the local community',
            style: AppTypography.caption,
          ),
        ],
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

  const _RestaurantCard({
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 1),
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
          // Background image
          restaurant.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: restaurant.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(
                    color: AppColors.neutral100,
                  ),
                  errorWidget: (_, _, _) => _ImagePlaceholder(),
                )
              : _ImagePlaceholder(),
          // Bottom gradient
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
          // Top-left dietary chips
          if (restaurant.dietaryTags.isNotEmpty)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Row(
                children: restaurant.dietaryTags
                    .map((tag) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: _buildDietaryOverlayChip(tag),
                        ))
                    .toList(),
              ),
            ),
          // Top-right pricing badge (image overlay style)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _PricingOverlayBadge(bracket: restaurant.pricingBracket),
          ),
          // Bottom overlay: name + distance
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
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.white,
                    ),
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
                        style: AppTypography.body2.copyWith(
                          color: AppColors.white,
                        ),
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

  Widget _buildDietaryOverlayChip(String tag) {
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

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: cuisine chip + walk time
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
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  restaurant.cuisineType,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral700),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 2),
              Text(
                '${restaurant.walkMinutes} min walk',
                style: AppTypography.body2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Row 2: recommendation reason card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primaryLight, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.thumb_up,
                  size: 18,
                  color: AppColors.primary,
                ),
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

// ── Image Placeholder ─────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
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

// ── Pricing Overlay Badge (white background for image overlays) ───────────────

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
