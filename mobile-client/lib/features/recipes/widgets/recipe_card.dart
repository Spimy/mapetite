import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_chip.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeCard extends ConsumerWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

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
              _RecipeImage(
                recipe: recipe,
                isSaved: isSaved,
                ref: ref,
              ),
              Expanded(
                child: _RecipeCardBody(
                  recipe: recipe,
                  saves: recipe.saves,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image Area ───────────────────────────────────────────────────────────────

class _RecipeImage extends StatelessWidget {
  final RecipeModel recipe;
  final bool isSaved;
  final WidgetRef ref;

  const _RecipeImage({
    required this.recipe,
    required this.isSaved,
    required this.ref,
  });

  Future<void> _toggleSaved(BuildContext context) async {
    try {
      await ref.read(savedRecipeIdsProvider.notifier).toggle(recipe.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update saved recipe.',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = recipe.thumbnailUrl;

    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildFallbackImage(),
            )
          else
            _buildFallbackImage(),
          if (recipe.isOwnedByCurrentUser &&
              recipe.visibility == RecipeVisibility.private)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.lock,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleSaved(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSaved ? AppColors.primary : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
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

  Widget _buildFallbackImage() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }
}

// ─── Card Body ────────────────────────────────────────────────────────────────

class _RecipeCardBody extends StatelessWidget {
  final RecipeModel recipe;
  final int saves;

  const _RecipeCardBody({
    required this.recipe,
    required this.saves,
  });

  @override
  Widget build(BuildContext context) {
    final chips = _buildChips();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chips.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: chips,
              ),
            ),
          if (chips.isNotEmpty) const SizedBox(height: AppSpacing.xs),
          Text(
            recipe.title,
            style: AppTypography.headline3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 12,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 2),
              Text('${recipe.cookMinutes}m', style: AppTypography.caption),
              const SizedBox(width: AppSpacing.xs + 2),
              const Icon(
                Icons.local_fire_department_outlined,
                size: 12,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  '${recipe.calories}kcal',
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              const Icon(
                Icons.bookmark_border,
                size: 12,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 2),
              Text('$saves', style: AppTypography.caption),
            ],
          ),
          const Spacer(),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    recipe.authorInitial,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'by ${recipe.authorName}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    if (recipe.isHalal) {
      chips.add(AppChip.halal());
    }

    if (recipe.isVegan) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 4));
      }

      chips.add(AppChip.vegan());
    }

    if (recipe.isVegetarian && !recipe.isVegan) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 4));
      }

      chips.add(AppChip.vegetarian());
    }

    if (recipe.isGlutenFree) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 4));
      }

      chips.add(AppChip.allergen('Gluten Free'));
    }

    if (recipe.cuisine != null) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 4));
      }

      chips.add(AppChip.cuisine(recipe.cuisine!));
    }

    return chips;
  }
}