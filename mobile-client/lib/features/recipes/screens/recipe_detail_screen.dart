import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/grocery/providers/grocery_list_provider.dart';
import '../../../shared/widgets/app_chip.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../providers/selected_ingredients_provider.dart';
import '../widgets/ingredient_row.dart';
import '../widgets/recipe_step_tile.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeIfNeeded();
    });
  }

  Future<void> _loadRecipeIfNeeded() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final recipe = await ref
        .read(recipeListProvider.notifier)
        .loadRecipeById(widget.recipeId);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = recipe == null ? 'Unable to load recipe details.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(recipeByIdProvider(widget.recipeId));

    if (recipe != null) {
      return _RecipeDetailContent(recipe: recipe);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _errorMessage ?? 'Recipe not found',
                      style: AppTypography.body1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: _loadRecipeIfNeeded,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RecipeDetailContent extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const _RecipeDetailContent({required this.recipe});

  @override
  ConsumerState<_RecipeDetailContent> createState() =>
      _RecipeDetailContentState();
}

class _RecipeDetailContentState extends ConsumerState<_RecipeDetailContent> {
  late final Set<String> _checkedIngredientKeys;
  int _activeStep = 1;
  bool _isSavingRecipe = false;

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

  Future<void> _toggleSavedRecipe(RecipeModel recipe) async {
    if (_isSavingRecipe) {
      return;
    }

    setState(() {
      _isSavingRecipe = true;
    });

    try {
      await ref.read(savedRecipeIdsProvider.notifier).toggle(recipe.id);
    } catch (_) {
      if (!mounted) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isSavingRecipe = false;
        });
      }
    }
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
          content: Row(
            children: [
              Expanded(
                child: Text(
                  'Select at least one available ingredient.',
                  style: AppTypography.body1.copyWith(color: AppColors.white),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.white,
                  size: 14,
                ),
              ),
            ],
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
          selected
              .map(
                (ing) => (
                  name: ing.name,
                  quantity: ing.quantity,
                  storeName: ing.storeName ?? 'Unknown Store',
                  cost: ing.estimatedCost ?? 0.0,
                ),
              )
              .toList(),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                '${selected.length} item${selected.length > 1 ? 's' : ''} added to My List',
                style: AppTypography.body1.copyWith(color: AppColors.white),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.white,
                size: 14,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  void _findGroceryStore() {
    final recipe = widget.recipe;
    final selected = recipe.ingredients.where((ing) {
      final key = '${recipe.id}_${ing.name}';
      return _checkedIngredientKeys.contains(key);
    }).toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Select at least one ingredient you need to buy.',
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

    ref.read(selectedIngredientsProvider.notifier).state = selected
        .map(
          (ing) => SelectedIngredient(
            name: ing.name,
            quantity: ing.quantity,
            storeName: ing.storeName,
            cost: ing.estimatedCost ?? 0.0,
          ),
        )
        .toList();

    context.push('/recipes/${recipe.id}/match');
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
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(recipe),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatsRow(recipe),
                  const SizedBox(height: AppSpacing.md),
                  _buildDietaryChips(recipe),
                  if (recipe.allergens.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildAllergenSection(recipe),
                  ],
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

  Widget _buildHero(BuildContext context, RecipeModel recipe) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/recipes');
          }
        },
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.neutral,
            size: 20,
          ),
        ),
      ),
      actions: [
        if (recipe.isOwnedByCurrentUser)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditRecipeScreen(recipe: recipe),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.neutral,
                  size: 20,
                ),
              ),
            ),
          ),
        Consumer(
          builder: (context, ref, _) {
            final isSaved = ref.watch(savedRecipeIdsProvider).contains(
                  recipe.id,
                );

            return GestureDetector(
              onTap: () => _toggleSavedRecipe(recipe),
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSaved ? AppColors.primary : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _isSavingRecipe
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color:
                              isSaved ? AppColors.white : AppColors.neutral,
                          size: 20,
                        ),
                ),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () => _showShareSheet(context, recipe),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.share_outlined,
                color: AppColors.neutral,
                size: 20,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.thumbnailUrl != null &&
                recipe.thumbnailUrl!.isNotEmpty
            ? Image.network(
                recipe.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildHeroPlaceholder(),
              )
            : _buildHeroPlaceholder(),
      ),
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(recipe: recipe),
    );
  }

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
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 1.5,
                ),
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
                  style: AppTypography.body2.copyWith(
                    color: AppColors.neutral,
                  ),
                ),
                Text(
                  'Posted ${recipe.timeAgo}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(RecipeModel recipe) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _StatChip(
          icon: Icons.timer_outlined,
          label: '${recipe.cookMinutes} min',
        ),
        _StatChip(
          icon: Icons.local_fire_department_outlined,
          label: '${recipe.calories} kcal',
        ),
        _StatChip(
          icon: Icons.people_outline,
          label: '${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}',
        ),
        if (recipe.cuisine != null)
          _StatChip(
            icon: AppConstants.cuisineIcons[recipe.cuisine!] ??
                Icons.restaurant_menu,
            label: recipe.cuisine!,
          ),
      ],
    );
  }

  Widget _buildDietaryChips(RecipeModel recipe) {
    final chips = <Widget>[];

    if (recipe.isHalal) {
      chips.add(AppChip.halal());
    }

    if (recipe.isVegan) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: AppSpacing.xs));
      }

      chips.add(AppChip.vegan());
    }

    if (recipe.isVegetarian && !recipe.isVegan) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: AppSpacing.xs));
      }

      chips.add(AppChip.vegetarian());
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(mainAxisSize: MainAxisSize.min, children: chips);
  }

  Widget _buildAllergenSection(RecipeModel recipe) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Contains:',
          style: AppTypography.caption.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        ...recipe.allergens.map((allergen) => AppChip.allergen(allergen)),
      ],
    );
  }

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
                style: AppTypography.label.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 13,
              color: AppColors.neutral400,
            ),
            const SizedBox(width: 4),
            Text(
              'Tap ingredients you need to buy',
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral400,
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
            children: recipe.ingredients.indexed.map((entry) {
              final (index, ingredient) = entry;
              final key = '${recipe.id}_${ingredient.name}';

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: IngredientRow(
                  ingredient: ingredient,
                  isChecked: _checkedIngredientKeys.contains(key),
                  onChanged: (_) => _toggleIngredient(key),
                  isLast: index == recipe.ingredients.length - 1,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToListButton() {
    final hasSelection = _checkedIngredientKeys.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _findGroceryStore,
            icon: const Icon(Icons.store_outlined, size: 20),
            label: Text(
              hasSelection
                  ? 'Find Grocery Store (${_checkedIngredientKeys.length})'
                  : 'Find Grocery Store',
              style: AppTypography.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasSelection ? AppColors.primary : AppColors.neutral400,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _addSelectedToGroceryList,
            icon: const Icon(
              Icons.playlist_add,
              size: 20,
              color: AppColors.primary,
            ),
            label: Text(
              'Add to My List',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        ...recipe.steps.asMap().entries.map(
              (entry) => RecipeStepTile(
                step: entry.value,
                isLast: entry.key == recipe.steps.length - 1,
                isActive: entry.value.stepNumber == _activeStep,
                onTap: () {
                  setState(() {
                    _activeStep = entry.value.stepNumber;
                  });
                },
              ),
            ),
      ],
    );
  }
}

class _ShareSheet extends StatelessWidget {
  final RecipeModel recipe;

  const _ShareSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusFull,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Share Recipe', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                recipe.title,
                style: AppTypography.body2.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ShareOption(
                icon: Icons.link_outlined,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Link copied to clipboard',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.chat_outlined,
                label: 'Share via WhatsApp',
                onTap: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Opening WhatsApp…',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.download_outlined,
                label: 'Save to Device',
                onTap: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Recipe saved to your device',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, size: 20, color: AppColors.neutral700),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.body1),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

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
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}