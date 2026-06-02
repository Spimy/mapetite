import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_chip.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeCard extends ConsumerWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedRecipeIdsProvider).contains(recipe.id);

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeImage(recipe: recipe, isSaved: isSaved, ref: ref),
              _RecipeCardBody(recipe: recipe),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final RecipeModel recipe;
  final bool isSaved;
  final WidgetRef ref;

  const _RecipeImage({required this.recipe, required this.isSaved, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppColors.primaryLight,
            child: const Center(
              child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 36),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (recipe.isHalal) AppChip.halal(),
                if (recipe.isHalal && (recipe.isVegan || recipe.isVegetarian))
                  const SizedBox(width: 4),
                if (recipe.isVegan) AppChip.vegan(),
                if (!recipe.isVegan && recipe.isVegetarian) AppChip.vegetarian(),
              ],
            ),
          ),
          if (recipe.isOwnedByCurrentUser &&
              recipe.visibility == RecipeVisibility.private)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.lock, size: 13, color: AppColors.white),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(savedRecipeIdsProvider.notifier).toggle(recipe.id),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSaved ? AppColors.primary : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 16,
                  color: isSaved ? AppColors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCardBody extends StatelessWidget {
  final RecipeModel recipe;

  const _RecipeCardBody({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: AppTypography.headline3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 12, color: AppColors.neutral600),
              const SizedBox(width: 2),
              Text('${recipe.cookMinutes}m', style: AppTypography.caption),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.neutral600),
              const SizedBox(width: 2),
              Text('${recipe.calories} kcal', style: AppTypography.caption),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.bookmark_border, size: 12, color: AppColors.neutral600),
              const SizedBox(width: 2),
              Text('${recipe.saves}', style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}
