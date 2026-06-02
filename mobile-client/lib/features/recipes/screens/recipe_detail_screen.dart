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
  int _activeStep = 1;

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
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
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
            child: Icon(Icons.arrow_back, color: AppColors.neutral, size: 20),
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final isSaved = ref.watch(savedRecipeIdsProvider).contains(recipe.id);
            return GestureDetector(
              onTap: () => ref.read(savedRecipeIdsProvider.notifier).toggle(recipe.id),
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
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? AppColors.white : AppColors.neutral,
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
              child: Icon(Icons.share_outlined, color: AppColors.neutral, size: 20),
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

  void _showShareSheet(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(recipe: recipe),
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
        const SizedBox(height: AppSpacing.md),
        ...recipe.steps.asMap().entries.map((e) => RecipeStepTile(
          step: e.value,
          isLast: e.key == recipe.steps.length - 1,
          isActive: e.value.stepNumber == _activeStep,
          onTap: () => setState(() => _activeStep = e.value.stepNumber),
        )),
      ],
    );
  }
}

// ─── Share Sheet ─────────────────────────────────────────────────────────────

class _ShareSheet extends StatelessWidget {
  final RecipeModel recipe;

  const _ShareSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Share Recipe', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                recipe.title,
                style: AppTypography.body2.copyWith(color: AppColors.neutral600),
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
                        style: AppTypography.body1.copyWith(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                        style: AppTypography.body1.copyWith(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.person_add_outlined,
                label: 'Send to a Friend',
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => _FriendSelectorSheet(recipe: recipe),
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
                        style: AppTypography.body1.copyWith(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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

  const _ShareOption({required this.icon, required this.label, required this.onTap});

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

// ─── Friend Selector Sheet ────────────────────────────────────────────────────

const _kMockFriends = [
  ('Aisha Rahman', 'A'),
  ('Ben Lim', 'B'),
  ('Chloe Tan', 'C'),
  ('David Wong', 'D'),
  ('Erica Malik', 'E'),
];

class _FriendSelectorSheet extends StatefulWidget {
  final RecipeModel recipe;

  const _FriendSelectorSheet({required this.recipe});

  @override
  State<_FriendSelectorSheet> createState() => _FriendSelectorSheetState();
}

class _FriendSelectorSheetState extends State<_FriendSelectorSheet> {
  final Set<String> _selected = {};

  void _send() {
    if (_selected.isEmpty) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recipe sent to ${_selected.length} friend${_selected.length > 1 ? 's' : ''}',
          style: AppTypography.body1.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Send to a Friend', style: AppTypography.headline2),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.recipe.title,
                    style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            ..._kMockFriends.map((f) {
              final isSelected = _selected.contains(f.$1);
              return InkWell(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selected.remove(f.$1);
                  } else {
                    _selected.add(f.$1);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 2,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            f.$2,
                            style: AppTypography.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(f.$1, style: AppTypography.body1),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: AppColors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty ? _send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.neutral200,
                    disabledForegroundColor: AppColors.neutral400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Select friends to send'
                        : 'Send to ${_selected.length} friend${_selected.length > 1 ? 's' : ''}',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
