import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/empty_feed_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/network_error_state.dart';
import '../models/mocks/home_feed_mocks.dart';
import '../../../routes/app_router.dart';
import '../../../features/notifications/providers/notification_provider.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/providers/store_providers.dart';
import '../../../shared/widgets/dialogs/location_permission_dialog.dart';
import '../../../shared/widgets/location_sheet.dart';
import 'package:geolocator/geolocator.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _cardAnim1;
  late Animation<Offset> _cardAnim2;
  double _radiusKm = AppConstants.defaultSearchRadiusKm;

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

    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocationPermission());
  }

  void _showLocationSheet(BuildContext context, WidgetRef ref) =>
      showLocationSheet(context);

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      showLocationPermissionDialog(context);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Greeting logic ──────────────────────────────────────────────────────────

  String _greetingLine2() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'Rise and shine! What\'s for breakfast?';
    if (hour >= 10 && hour < 11) return 'Brunch o\'clock! Where are we eating?';
    if (hour >= 11 && hour < 14) return 'Lunch time! What are you craving?';
    if (hour >= 14 && hour < 17) return 'Afternoon vibes! Time for a snack?';
    if (hour >= 17 && hour < 21) return 'Dinner time! Where to tonight?';
    if (hour >= 21 && hour < 23) return 'Still going? Let\'s find something good.';
    return 'Night owl! There\'s always supper.';
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider).valueOrNull;
    final lat = location?.latitude ?? 3.0731;
    final lng = location?.longitude ?? 101.6069;
    final restaurantQuery = NearbyStoresQuery(
      lat: lat,
      lng: lng,
      radiusKm: _radiusKm,
      type: StoreType.restaurant,
    );
    final groceryQuery = NearbyStoresQuery(
      lat: lat,
      lng: lng,
      radiusKm: _radiusKm,
      type: StoreType.grocery,
    );
    final restaurantsAsync = ref.watch(nearbyStoresProvider(restaurantQuery));
    final groceriesAsync = ref.watch(nearbyStoresProvider(groceryQuery));
    final displayName =
        ref.watch(authControllerProvider).currentUser?.displayName ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        displayName: displayName,
        savedThisMonth: 47.50,
      ),
      body: SafeArea(
        child: restaurantsAsync.when(
          loading: () => const HomeFeedSkeleton(),
          error: (error, _) => error is AppException && error.isNetworkError
              ? NetworkErrorState(
                  onRetry: () {
                    ref.invalidate(nearbyStoresProvider(restaurantQuery));
                    ref.invalidate(nearbyStoresProvider(groceryQuery));
                  },
                )
              : AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  description: 'Unable to load your feed. Please try again.',
                  ctaLabel: 'Retry',
                  onCta: () {
                    ref.invalidate(nearbyStoresProvider(restaurantQuery));
                    ref.invalidate(nearbyStoresProvider(groceryQuery));
                  },
                ),
          data: (restaurants) => groceriesAsync.when(
            loading: () => const HomeFeedSkeleton(),
            error: (error, _) => error is AppException && error.isNetworkError
                ? NetworkErrorState(
                    onRetry: () =>
                        ref.invalidate(nearbyStoresProvider(groceryQuery)),
                  )
                : AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    description: 'Unable to load your feed. Please try again.',
                    ctaLabel: 'Retry',
                    onCta: () => ref.invalidate(nearbyStoresProvider(groceryQuery)),
                  ),
            data: (groceries) => restaurants.isEmpty && groceries.isEmpty
                ? EmptyFeedState(
                    ctaLabel: 'Expand Radius',
                    onCta: () => setState(
                      () => _radiusKm = AppConstants.maxSearchRadiusKm,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(
                        child: _buildContent(restaurants, groceries),
                      ),
                    ],
                  ),
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
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'assets/logos/logo_wording.svg',
                  height: 54,
                  fit: BoxFit.contain,
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

  Widget _buildContent(
    List<StoreModel> restaurants,
    List<StoreModel> groceries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildModeCards(restaurants),
        const SizedBox(height: AppSpacing.xxl),
        _buildNearbySection(restaurants),
        const SizedBox(height: AppSpacing.xxl),
        _buildGroceriesSection(groceries),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  // ─── Greeting section ────────────────────────────────────────────────────────

  Widget _buildGreetingSection() {
    final displayName =
        ref.watch(authControllerProvider).currentUser?.displayName ?? '';

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
            'Hi, $displayName.',
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
              Flexible(
                child: GestureDetector(
                  onTap: () => _showLocationSheet(context, ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          ref.watch(locationCityProvider),
                          style: AppTypography.body1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Mode Cards ──────────────────────────────────────────────────────────────

  Widget _buildModeCards(List<StoreModel> restaurants) {
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
                  nearbyCount: restaurants.length,
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

  // ─── Nearby Options ──────────────────────────────────────────────────────────

  Widget _buildNearbySection(List<StoreModel> restaurants) {
    final nearby = restaurants.take(3).toList();
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
          ...nearby.map(
            (store) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _NearbyRow(
                store: store,
                onTap: () =>
                    context.push('${AppRoutes.restaurants}/${store.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Nearby Groceries ────────────────────────────────────────────────────────

  Widget _buildGroceriesSection(List<StoreModel> groceries) {
    final nearby = groceries.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Groceries',
            style: AppTypography.headline2.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: AppSpacing.md),
          ...nearby.map(
            (store) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _GroceryRow(
                store: store,
                onTap: () =>
                    context.push('${AppRoutes.groceries}/${store.id}'),
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
  final int nearbyCount;
  final VoidCallback onTap;
  const _DineInCard({required this.nearbyCount, required this.onTap});

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
                                '$nearbyCount nearby',
                                style: AppTypography.headline3.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.white.withValues(alpha: 0.7),
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
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.neutral400,
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

// ─── Nearby Row ───────────────────────────────────────────────────────────────

class _NearbyRow extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _NearbyRow({required this.store, required this.onTap});

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
                child: store.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: store.imageUrl!,
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
                    store.businessName,
                    style: AppTypography.headline3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
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
                  const SizedBox(height: AppSpacing.xs),
                  if (store.dietaryTags.contains('Halal'))
                    const DietaryChip.halal()
                  else if (store.dietaryTags.contains('Vegan'))
                    const DietaryChip.vegan(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
                  '${store.walkMinutesEstimate ?? '—'}m',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grocery Row ──────────────────────────────────────────────────────────────

class _GroceryRow extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _GroceryRow({required this.store, required this.onTap});

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
                child: store.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: store.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.neutral100,
                          highlightColor: AppColors.white,
                          child: Container(color: AppColors.neutral100),
                        ),
                        errorWidget: (context, url, err) => Container(
                          color: AppColors.neutral100,
                          child: const Icon(Icons.local_grocery_store,
                              size: 24, color: AppColors.neutral400),
                        ),
                      )
                    : Container(
                        color: AppColors.neutral100,
                        child: const Icon(Icons.local_grocery_store,
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
                    store.businessName,
                    style: AppTypography.headline3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
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
                  const SizedBox(height: AppSpacing.xs),
                  if (store.dietaryTags.contains('Halal'))
                    const DietaryChip.halal()
                  else if (store.dietaryTags.contains('Vegan'))
                    const DietaryChip.vegan(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
                  '${store.walkMinutesEstimate ?? '—'}m',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral400,
                  ),
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

