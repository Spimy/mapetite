import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/home_feed_models.dart';
import '../models/mocks/home_feed_mocks.dart';
import '../providers/home_feed_providers.dart';
import '../../../routes/app_router.dart';
import '../../../features/notifications/providers/notification_provider.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _cardAnim1;
  late Animation<Offset> _cardAnim2;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _cardAnim1 = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _cardAnim2 = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
    ));

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: false);

    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ─── Greeting logic ──────────────────────────────────────────────────────────

  String _greetingLine2() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return "Good morning — what's for breakfast?";
    if (hour >= 10 && hour < 11) return "It's brunch o'clock — where to?";
    if (hour >= 11 && hour < 14) return "It's lunchtime — what are you feeling?";
    if (hour >= 14 && hour < 17) return "Afternoon — time for a treat?";
    if (hour >= 17 && hour < 21) return "Dinner time — where to tonight?";
    if (hour >= 21 && hour < 23) return "Evening — still hungry?";
    return "Late night — there's always supper.";
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

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
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: SizedBox(
        height: AppSpacing.appBarHeight,
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Open menu',
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Mapetite',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            _BellButton(
              onTap: () => context.push(AppRoutes.notifications),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Content ─────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingSection(),
        const SizedBox(height: AppSpacing.md),
        _buildAiNudgePill(),
        const SizedBox(height: AppSpacing.lg),
        _buildModeCards(),
        const SizedBox(height: AppSpacing.xxl),
        _buildTopPickSection(),
        const SizedBox(height: AppSpacing.xxl),
        _buildNearbySection(),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  // ─── Greeting section ────────────────────────────────────────────────────────

  Widget _buildGreetingSection() {
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
          Text(
            'Hi, ${HomeFeedMocks.userName}.',
            style: AppTypography.display.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _greetingLine2(),
            style: AppTypography.display.copyWith(
              color: AppColors.neutral,
              fontWeight: FontWeight.w400,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'RM ${HomeFeedMocks.budgetRemaining.toStringAsFixed(0)}',
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'left this month · ',
                style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              ),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 2),
              Text(
                HomeFeedMocks.userLocation,
                style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── AI nudge card ───────────────────────────────────────────────────────────

  Widget _buildAiNudgePill() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Shimmer sweep overlay
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(
                          _shimmerAnim.value *
                              MediaQuery.of(context).size.width,
                          0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0.3, 0.5, 0.7],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Left accent bar
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppSpacing.radiusXl),
                            bottomLeft: Radius.circular(AppSpacing.radiusXl),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg + 3,
                        AppSpacing.md + 2,
                        AppSpacing.lg,
                        AppSpacing.md + 2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Glow orb
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.85),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AI SUGGESTION',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    style: AppTypography.body1.copyWith(
                                      color: AppColors.neutral700,
                                      height: 1.3,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: 'Based on your preferences, '),
                                      TextSpan(
                                        text: 'Dine-In',
                                        style: AppTypography.body1.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(
                                          text: ' is your best bet right now.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Mode Cards ──────────────────────────────────────────────────────────────

  Widget _buildModeCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _cardAnim1,
                child: _DineInCard(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.dineIn);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _cardAnim2,
                child: _CookInCard(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go(AppRoutes.cookIn);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Today's Top Pick ────────────────────────────────────────────────────────

  Widget _buildTopPickSection() {
    final restaurant = HomeFeedMocks.topPick;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Top Pick",
            style: AppTypography.headline2.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => context.push(AppRoutes.dineIn),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopPickHeroImage(restaurant: restaurant),
                  _TopPickBody(restaurant: restaurant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Nearby Options ──────────────────────────────────────────────────────────

  Widget _buildNearbySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Options',
                style: AppTypography.headline2.copyWith(color: AppColors.neutral),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.map),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View map',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...HomeFeedMocks.nearbyOptions.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _NearbyRow(
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
}

// ─── Dine-In Card ─────────────────────────────────────────────────────────────

class _DineInCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DineInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 190,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF065F46), Color(0xFF0D7A5E)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF065F46).withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Stack(
              children: [
                // Decorative blob top-right
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Smaller blob bottom-left
                Positioned(
                  bottom: -16,
                  left: -16,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_outlined,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dine-In',
                            style: AppTypography.headline2.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Find a restaurant',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Divider(
                            color: AppColors.white.withValues(alpha: 0.2),
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '3 nearby',
                                style: AppTypography.headline3.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Check badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 14,
                    ),
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

// ─── Cook-In Card ─────────────────────────────────────────────────────────────

class _CookInCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CookInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 190,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Stack(
              children: [
                // Subtle decorative blob
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.soup_kitchen_outlined,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cook-In',
                            style: AppTypography.headline2.copyWith(
                              color: AppColors.neutral,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Pick a recipe',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(
                            color: AppColors.border,
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book_outlined,
                                size: 16,
                                color: AppColors.neutral600,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '4 saved',
                                style: AppTypography.headline3.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
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

// ─── Top Pick sub-widgets ─────────────────────────────────────────────────────

class _TopPickHeroImage extends StatelessWidget {
  final RestaurantSummary restaurant;
  const _TopPickHeroImage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: SizedBox(
        height: 128,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            restaurant.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: restaurant.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const CardShimmer(height: 128),
                    errorWidget: (_, _, _) => Container(
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
            if (restaurant.isHalal)
              const Positioned(
                top: 12,
                left: 12,
                child: DietaryChip.halal(),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
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
                      'Est. RM 25',
                      style: AppTypography.label.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: AppTypography.headline3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${restaurant.cuisine} · ${restaurant.distanceKm.toStringAsFixed(1)}km away',
            style: AppTypography.body2.copyWith(color: AppColors.neutral600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Nearby Row ───────────────────────────────────────────────────────────────

class _NearbyRow extends StatelessWidget {
  final RestaurantSummary restaurant;
  final VoidCallback onTap;

  const _NearbyRow({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: SizedBox(
                width: 64,
                height: 64,
                child: restaurant.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.neutral100,
                          highlightColor: AppColors.white,
                          child: Container(color: AppColors.neutral100),
                        ),
                        errorWidget: (context, url, err) => Container(
                          color: AppColors.neutral100,
                          child: const Icon(Icons.restaurant,
                              size: 24, color: AppColors.neutral400),
                        ),
                      )
                    : Container(
                        color: AppColors.neutral100,
                        child: const Icon(Icons.restaurant,
                            size: 24, color: AppColors.neutral400),
                      ),
              ),
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
                    '${restaurant.cuisine} · ${restaurant.distanceKm.toStringAsFixed(1)}km',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (restaurant.isHalal)
                    const DietaryChip.halal()
                  else if (restaurant.isVegan)
                    const DietaryChip.vegan(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (restaurant.pricingBracket != null)
                  Text(
                    restaurant.pricingBracket!,
                    style: AppTypography.headline3.copyWith(
                      color: AppColors.neutral,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.walkMinutes}m',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bell Button with Badge ───────────────────────────────────────────────────

class _BellButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _BellButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: AppColors.primary),
          if (count > 0)
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
                    count > 9 ? '9+' : '$count',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
