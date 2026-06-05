import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/food_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/mode_choice_sheet.dart';
import '../models/home_feed_models.dart';
import '../models/mocks/home_feed_mocks.dart';
import '../providers/home_feed_providers.dart';
import '../../../routes/app_router.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    return 'Good evening.';
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(
        displayName: HomeFeedMocks.userName,
        savedThisMonth: 47.50,
      ),
      body: SafeArea(
        child: feed.when(
          loading: () => const HomeFeedSkeleton(),
          error: (_, _) => const AppEmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            description: 'Unable to load your feed. Please try again.',
          ),
          data: (_) => CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildContent()),
            ],
          ),
        ),
      ),
      floatingActionButton: feed.hasValue ? _buildFAB() : null,
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SizedBox(
          height: AppSpacing.appBarHeight,
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.neutral),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  tooltip: 'Open menu',
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Home',
                    style: AppTypography.headline1
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.neutral),
                onPressed: () {},
                tooltip: 'Search',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreeting(),
        const SizedBox(height: AppSpacing.xxl),
        _buildTopPickSection(),
        const SizedBox(height: AppSpacing.xxl),
        _buildCookInSection(),
        const SizedBox(height: AppSpacing.xxl),
        _buildNearbySection(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // ─── Greeting ───────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting(), style: AppTypography.display),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ready to explore healthy options today?',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  // ─── Today's Top Pick ───────────────────────────────────────────────────────

  Widget _buildTopPickSection() {
    final restaurant = HomeFeedMocks.topPick;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Top Pick", style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            key: const Key('top_pick_card'),
            onTap: () => context.push(AppRoutes.dineIn),
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopPickImage(restaurant: restaurant),
                  _TopPickBody(restaurant: restaurant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cook Something? ────────────────────────────────────────────────────────

  Widget _buildCookInSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cook Something?', style: AppTypography.headline3),
              TextButton(
                onPressed: () => context.push(AppRoutes.cookIn),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Browse Recipes',
                  style:
                      AppTypography.body2.copyWith(color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: HomeFeedMocks.cookInRecipes.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, i) {
              final r = HomeFeedMocks.cookInRecipes[i];
              return RecipeHorizontalCard(
                recipe: r,
                onTap: () => context.push(AppRoutes.cookIn),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Nearby Options ─────────────────────────────────────────────────────────

  Widget _buildNearbySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nearby Options', style: AppTypography.headline3),
              TextButton(
                onPressed: () => context.go(AppRoutes.restaurants),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...HomeFeedMocks.nearbyRestaurants.take(2).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NearbyRestaurantRow(
                    restaurant: r,
                    onTap: () =>
                        context.go('${AppRoutes.restaurants}/${r.id}'),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ─── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => showModeChoiceSheet(context),
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }
}

// ─── Top Pick sub-widgets ────────────────────────────────────────────────────

class _TopPickImage extends StatelessWidget {
  final RestaurantSummary restaurant;
  const _TopPickImage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: SizedBox(
        height: 192,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            restaurant.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: restaurant.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Shimmer.fromColors(
                      baseColor: AppColors.neutral100,
                      highlightColor: AppColors.neutral200,
                      child: Container(color: AppColors.neutral100),
                    ),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.neutral100),
                  )
                : Container(
                    color: AppColors.neutral100,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: AppSpacing.iconLg,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  if (restaurant.isHalal) const DietaryChip.halal(),
                  const SizedBox(width: AppSpacing.xs),
                  const _HealthyChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopPickBody extends StatelessWidget {
  final RestaurantSummary restaurant;
  const _TopPickBody({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: AppTypography.headline2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Flexible(
                child: Text(
                  restaurant.cuisine,
                  style: AppTypography.body2
                      .copyWith(color: AppColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.star, size: 13, color: AppColors.warning),
              const SizedBox(width: 3),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style:
                    AppTypography.body2.copyWith(color: AppColors.neutral600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 13,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 3),
              Text(
                '${restaurant.distanceKm.toStringAsFixed(1)} km away',
                style:
                    AppTypography.body2.copyWith(color: AppColors.neutral600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthyChip extends StatelessWidget {
  const _HealthyChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Healthy',
        style: AppTypography.label.copyWith(color: AppColors.white),
      ),
    );
  }
}
