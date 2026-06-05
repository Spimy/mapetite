import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../features/discovery/models/home_feed_models.dart';
import 'dietary_chip.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;
    return Material(
      color: backgroundColor ?? AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Restaurant Mini-Card ────────────────────────────────────────────────────

class RestaurantMiniCard extends StatelessWidget {
  final RestaurantSummary restaurant;
  final VoidCallback onTap;

  const RestaurantMiniCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with dietary chips overlaid bottom-left
              SizedBox(
                height: 112,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.neutral100,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.neutral400,
                          size: AppSpacing.iconLg,
                        ),
                      ),
                    ),
                    if (restaurant.isHalal || restaurant.isVegan)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (restaurant.isHalal)
                                const DietaryChip(tag: DietaryTag.halal),
                              if (restaurant.isHalal && restaurant.isVegan)
                                const SizedBox(width: AppSpacing.xs),
                              if (restaurant.isVegan)
                                const DietaryChip(tag: DietaryTag.vegan),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Name + rating/distance below image
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: AppTypography.headline3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${restaurant.rating.toStringAsFixed(1)} ★  ·  ${restaurant.distanceKm.toStringAsFixed(1)} km',
                      style: AppTypography.caption,
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

// ─── Grocery Grid-Card ────────────────────────────────────────────────────────

class GroceryMiniCard extends StatelessWidget {
  final GrocerySummary grocery;
  final VoidCallback onTap;

  const GroceryMiniCard({
    super.key,
    required this.grocery,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.neutral400,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              grocery.name,
              style: AppTypography.headline3,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${grocery.type}  ·  ${grocery.distanceKm.toStringAsFixed(1)} km',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe List Card ─────────────────────────────────────────────────────────

class RecipeMiniCard extends StatefulWidget {
  final RecipeSummary recipe;
  final VoidCallback onTap;

  const RecipeMiniCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  State<RecipeMiniCard> createState() => _RecipeMiniCardState();
}

class _RecipeMiniCardState extends State<RecipeMiniCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(
                    Icons.set_meal,
                    color: AppColors.primary,
                    size: AppSpacing.iconLg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dietary chips + time (horizontal scroll to prevent overflow)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (recipe.isHalal)
                          const DietaryChip(tag: DietaryTag.halal),
                        if (recipe.isHalal && recipe.isVegan)
                          const SizedBox(width: AppSpacing.xs),
                        if (recipe.isVegan)
                          const DietaryChip(tag: DietaryTag.vegan),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '·  ${recipe.prepMinutes} min',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    recipe.name,
                    style: AppTypography.headline3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(recipe.cuisine, style: AppTypography.body2),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // TODO: Route to /my-list — favourites / saved recipes
            GestureDetector(
              onTap: () => setState(() => _saved = !_saved),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _saved ? AppColors.primaryLight : AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _saved ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe Horizontal Card (Cook-In row) ──────────────────────────────────────

class RecipeHorizontalCard extends StatelessWidget {
  final RecipeSummary recipe;
  final VoidCallback onTap;

  const RecipeHorizontalCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: recipe.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Shimmer.fromColors(
                          baseColor: AppColors.neutral100,
                          highlightColor: AppColors.neutral200,
                          child: Container(color: AppColors.neutral100),
                        ),
                        errorWidget: (_, _, _) => _RecipeImagePlaceholder(),
                      )
                    : _RecipeImagePlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTypography.headline3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${recipe.prepMinutes} min  ·  ${recipe.calories} kcal',
                      style: AppTypography.body2
                          .copyWith(color: AppColors.neutral600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (recipe.isHalal) const DietaryChip.halal(),
                        if (recipe.isVegan) const DietaryChip.vegan(),
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

class _RecipeImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(Icons.restaurant, size: 40, color: AppColors.primary),
      ),
    );
  }
}

// ─── Nearby Restaurant Row (Nearby Options section) ───────────────────────────

class NearbyRestaurantRow extends StatelessWidget {
  final RestaurantSummary restaurant;
  final VoidCallback onTap;

  const NearbyRestaurantRow({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 1),
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
                        placeholder: (_, _) => Shimmer.fromColors(
                          baseColor: AppColors.neutral100,
                          highlightColor: AppColors.neutral200,
                          child: Container(color: AppColors.neutral100),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.neutral100,
                          child: const Icon(Icons.restaurant,
                              color: AppColors.neutral400, size: 28),
                        ),
                      )
                    : Container(
                        color: AppColors.neutral100,
                        child: const Icon(Icons.restaurant,
                            color: AppColors.neutral400, size: 28),
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${restaurant.cuisine}  ·  ${restaurant.distanceKm.toStringAsFixed(1)} km',
                    style: AppTypography.body2
                        .copyWith(color: AppColors.neutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 13, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTypography.body2
                            .copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (restaurant.isHalal) const DietaryChip.halal(),
                      if (restaurant.isHalal && restaurant.isVegan)
                        const SizedBox(width: AppSpacing.xs),
                      if (restaurant.isVegan) const DietaryChip.vegan(),
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
