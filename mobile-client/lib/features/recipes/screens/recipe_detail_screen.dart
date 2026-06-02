import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../features/grocery/providers/grocery_list_provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/ingredient_row.dart';
import '../widgets/recipe_step_tile.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeByIdProvider(recipeId));

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: const BackButton(color: AppColors.primary),
        ),
        body: Center(
          child: Text('Recipe not found', style: AppTypography.body1),
        ),
      );
    }

    return _RecipeDetailContent(recipe: recipe);
  }
}

class _RecipeDetailContent extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const _RecipeDetailContent({required this.recipe});

  @override
  ConsumerState<_RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends ConsumerState<_RecipeDetailContent> {
  late final Set<String> _checkedIngredientKeys;

  @override
  void initState() {
    super.initState();
    _checkedIngredientKeys = {};
  }

  void _toggleIngredient(String key) {
    setState(() {
      if (_checkedIngredientKeys.contains(key)) {
        _checkedIngredientKeys.remove(key);
      } else {
        _checkedIngredientKeys.add(key);
      }
    });
  }

  void _addSelectedToGroceryList() {
    final recipe = widget.recipe;
    final selected = recipe.ingredients.where((ing) {
      final key = '${recipe.id}_${ing.name}';
      return _checkedIngredientKeys.contains(key) && !ing.notSourcedNearby;
    }).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select at least one available ingredient.',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
      return;
    }

    ref.read(groceryListProvider.notifier).addFromIngredients(
      selected.map((ing) => (
        name: ing.name,
        quantity: ing.quantity,
        storeName: ing.storeName ?? 'Unknown Store',
        cost: ing.estimatedCost ?? 0.0,
      )).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selected.length} item${selected.length > 1 ? 's' : ''} added to My List',
          style: AppTypography.body1.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        action: SnackBarAction(
          label: 'View List',
          textColor: AppColors.primaryLight,
          onPressed: () => context.push('/my-list'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHero(context, recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(recipe),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatsRow(recipe),
                  const SizedBox(height: AppSpacing.md),
                  _buildDietaryChips(recipe),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildIngredientsSection(recipe),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAddToListButton(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildStepsSection(recipe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero ─────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, RecipeModel recipe) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.share_outlined, color: AppColors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primaryLight,
          child: const Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Title & Author ───────────────────────────────────────────────────────

  Widget _buildTitleSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.title, style: AppTypography.headline1),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight, width: 1.5),
              ),
              child: Center(
                child: Text(
                  recipe.authorInitial,
                  style: AppTypography.label.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'by ${recipe.authorName}',
                  style: AppTypography.body2.copyWith(color: AppColors.neutral),
                ),
                Text(
                  'Posted ${recipe.postedAgo}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(RecipeModel recipe) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.timer_outlined,
          label: '${recipe.cookMinutes} min',
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          icon: Icons.local_fire_department_outlined,
          label: '${recipe.calories} kcal',
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(
          icon: Icons.people_outline,
          label: '${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}',
        ),
      ],
    );
  }

  // ─── Dietary Chips ────────────────────────────────────────────────────────

  Widget _buildDietaryChips(RecipeModel recipe) {
    final chips = <Widget>[];
    if (recipe.isHalal) chips.add(AppChip.halal());
    if (recipe.isVegan) {
      if (chips.isNotEmpty) chips.add(const SizedBox(width: AppSpacing.xs));
      chips.add(AppChip.vegan());
    }
    if (recipe.isVegetarian && !recipe.isVegan) {
      if (chips.isNotEmpty) chips.add(const SizedBox(width: AppSpacing.xs));
      chips.add(AppChip.vegetarian());
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: chips);
  }

  // ─── Ingredients ──────────────────────────────────────────────────────────

  Widget _buildIngredientsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ingredients', style: AppTypography.headline2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '${recipe.ingredients.length} items',
                style: AppTypography.label.copyWith(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: recipe.ingredients.map((ing) {
              final key = '${recipe.id}_${ing.name}';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: IngredientRow(
                  ingredient: ing,
                  isChecked: _checkedIngredientKeys.contains(key),
                  onChanged: (_) => _toggleIngredient(key),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── CTA ──────────────────────────────────────────────────────────────────

  Widget _buildAddToListButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _addSelectedToGroceryList,
        icon: const Icon(Icons.playlist_add, size: 20),
        label: Text('Add Selected to Grocery List', style: AppTypography.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ─── Steps ────────────────────────────────────────────────────────────────

  Widget _buildStepsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.sm),
        ...recipe.steps.map((step) => RecipeStepTile(step: step)),
      ],
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.neutral600),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.label.copyWith(color: AppColors.neutral600)),
        ],
      ),
    );
  }
}
