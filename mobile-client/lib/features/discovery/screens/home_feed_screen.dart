import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/food_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/profile_drawer.dart';
import '../../../routes/app_router.dart';
import '../models/home_feed_models.dart';
import '../models/mocks/home_feed_mocks.dart';
import '../providers/home_feed_providers.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, ${HomeFeedMocks.userName}';
    if (hour < 17) return 'Good afternoon, ${HomeFeedMocks.userName}';
    return 'Good evening, ${HomeFeedMocks.userName}';
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final isEmpty = HomeFeedMocks.nearbyRestaurants.isEmpty &&
        HomeFeedMocks.nearbyGroceries.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Profile drawer — slides in from the left when the avatar is tapped
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: feed.when(
          loading: () => const HomeFeedSkeleton(),
          error: (e, s) => const _ErrorState(),
          data: (_) => isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(child: _buildContent()),
                  ],
                ),
        ),
      ),
      floatingActionButton: feed.hasValue ? _buildFAB() : null,
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      scrolledUnderElevation: 2,
      titleSpacing: AppSpacing.lg,
      automaticallyImplyLeading: false,
      title: _buildAppBarTitle(),
    );
  }

  Widget _buildAppBarTitle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Left: profile avatar — tapping opens the profile drawer
        Align(
          alignment: Alignment.centerLeft,
          child: Builder(
            builder: (drawerCtx) => GestureDetector(
              // TODO: Opens profile drawer → profile details, navigation shortcuts
              onTap: () => Scaffold.of(drawerCtx).openDrawer(),
              child: _buildProfileAvatar(),
            ),
          ),
        ),
        // Centre: app name — truly centred by Stack regardless of side widths
        Text(
          'Mapetite',
          style: AppTypography.headline2.copyWith(color: AppColors.primary),
        ),
        // Right: notification bell
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            // TODO: Navigate to /notifications — alerts for deals, order updates
            onTap: () => context.push(AppRoutes.notifications),
            child: _buildBellIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(color: AppColors.primaryLight, width: 2),
      ),
      child: Center(
        child: Text(
          HomeFeedMocks.userName[0],
          style: AppTypography.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildBellIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(
          Icons.notifications_outlined,
          size: AppSpacing.iconMd,
          color: AppColors.neutral,
        ),
        if (HomeFeedMocks.notificationCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Location Pill ────────────────────────────────────────────────────────

  Widget _buildLocationPill() {
    // TODO: Navigate to location picker → change delivery/browse area
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 12, color: AppColors.primary),
            const SizedBox(width: 2),
            Text(
              HomeFeedMocks.userLocation,
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, size: 13, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ─── Scrollable Content ───────────────────────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting + location
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: AppTypography.display),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ready for a delicious day?',
                style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Top Pick For You
        _buildSection(
          title: 'Top Pick For You',
          titleIcon: const Icon(Icons.stars_rounded, color: AppColors.warning, size: 20),
          onSeeAll: null,
          trailing: _buildLocationPill(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildFeaturedCard(HomeFeedMocks.nearbyRestaurants.first),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Nearby Restaurants
        _buildSection(
          title: 'Nearby Restaurants',
          // TODO: Pass restaurants filter to Explore when it supports deep-linking
          onSeeAll: () => context.go(AppRoutes.explore),
          child: SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: HomeFeedMocks.nearbyRestaurants.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) {
                final r = HomeFeedMocks.nearbyRestaurants[i];
                return RestaurantMiniCard(
                  restaurant: r,
                  onTap: () => context.go('/restaurants/${r.id}'),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Near You Grocery
        _buildSection(
          title: 'Near You Grocery',
          // TODO: Pass grocery filter to Explore when it supports deep-linking
          onSeeAll: () => context.go(AppRoutes.explore),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
              ),
              itemCount: HomeFeedMocks.nearbyGroceries.length,
              itemBuilder: (_, i) {
                final g = HomeFeedMocks.nearbyGroceries[i];
                return GroceryMiniCard(grocery: g, onTap: () {});
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Trending Recipes
        _buildSection(
          title: 'Trending Recipes',
          onSeeAll: () => context.push(AppRoutes.recipes),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: HomeFeedMocks.trendingRecipes.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => RecipeMiniCard(
                recipe: HomeFeedMocks.trendingRecipes[i],
                onTap: () => context.push('/recipes/${HomeFeedMocks.trendingRecipes[i].id}'),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Budget This Month
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _buildBudgetCard(HomeFeedMocks.currentBudget),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ─── Featured Card (Top Pick) ─────────────────────────────────────────────

  Widget _buildFeaturedCard(RestaurantSummary restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hero image with gradient overlay and content
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image placeholder (TODO: CachedNetworkImage)
                  Container(
                    color: AppColors.neutral100,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                  // Bottom gradient for text legibility
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xBF000000)],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),
                  // Top-left: dietary + cuisine tags
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (restaurant.isHalal)
                          const DietaryChip(tag: DietaryTag.halal),
                        if (restaurant.isVegan) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const DietaryChip(tag: DietaryTag.vegan),
                        ],
                        const SizedBox(width: AppSpacing.xs),
                        _CuisineTag(restaurant.cuisine),
                      ],
                    ),
                  ),
                  // Top-right: AI match badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Match ${restaurant.matchScore.toInt()}%',
                            style: AppTypography.label.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom: restaurant name, location, rating
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                restaurant.name,
                                style: AppTypography.headline1.copyWith(
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 13,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      '${restaurant.distanceKm.toStringAsFixed(1)} km away  ·  ${restaurant.walkMinutes} min walk',
                                      style: AppTypography.body2.copyWith(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: AppTypography.button.copyWith(
                                  fontSize: 13,
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
            ),
          ),
          // Get Directions CTA
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Get Directions',
              leadingIcon: Icons.directions_rounded,
              // TODO: Navigate to /directions — map route to selected restaurant
              onPressed: () => context.push(AppRoutes.directions),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section wrapper ──────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    Widget? titleIcon,
    required VoidCallback? onSeeAll,
    Widget? trailing,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (titleIcon != null) ...[
                    titleIcon,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(title, style: AppTypography.headline2),
                ],
              ),
              if (trailing != null)
                trailing
              else if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
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
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }

  // ─── Budget Card ──────────────────────────────────────────────────────────

  Widget _buildBudgetCard(BudgetStatus budget) {
    final pct = (budget.percentage * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Food & Groceries',
                    style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'RM ${budget.spent.toStringAsFixed(0)}',
                          style: AppTypography.headline1,
                        ),
                        TextSpan(
                          text: ' / RM ${budget.monthlyLimit.toStringAsFixed(0)}',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '$pct%',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: budget.percentage,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'RM ${budget.remaining.toStringAsFixed(0)} remaining',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty + FAB ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.map_outlined,
      title: 'Nothing nearby yet',
      description:
          "We couldn't find restaurants or stores near ${HomeFeedMocks.userLocation}. "
          'Try expanding your search radius.',
      ctaLabel: 'Explore Map',
      onCta: () => context.go('/explore'),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: 'Unable to load your feed. Please try again.',
    );
  }
}

class _CuisineTag extends StatelessWidget {
  final String label;

  const _CuisineTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: AppColors.white),
      ),
    );
  }
}
