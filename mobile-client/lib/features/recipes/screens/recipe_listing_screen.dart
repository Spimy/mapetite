import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/profile_drawer.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/add_recipe_sheet.dart';

class RecipeListingScreen extends ConsumerStatefulWidget {
  const RecipeListingScreen({super.key});

  @override
  ConsumerState<RecipeListingScreen> createState() => _RecipeListingScreenState();
}

class _RecipeListingScreenState extends ConsumerState<RecipeListingScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddRecipeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(filteredRecipesProvider);
    final filterState = ref.watch(recipeFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildSearchBar(filterState)),
            SliverToBoxAdapter(child: _buildFilterChips(filterState)),
            SliverToBoxAdapter(child: _buildSortTabs(filterState)),
            recipes.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      onClear: () => ref.read(recipeFilterProvider.notifier).clearFilters(),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = recipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            onTap: () => context.push('/recipes/${recipe.id}'),
                          );
                        },
                        childCount: recipes.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.78,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 3,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      scrolledUnderElevation: 2,
      titleSpacing: AppSpacing.lg,
      automaticallyImplyLeading: false,
      title: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (drawerCtx) => GestureDetector(
                onTap: () => Scaffold.of(drawerCtx).openDrawer(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text('Recipes', style: AppTypography.headline2.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(RecipeFilterState filterState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => ref.read(recipeFilterProvider.notifier).setSearch(v),
        style: AppTypography.body1,
        decoration: InputDecoration(
          hintText: 'Search recipes or ingredients...',
          hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral400, size: 20),
          suffixIcon: filterState.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.neutral400),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(recipeFilterProvider.notifier).setSearch('');
                  },
                )
              : const Icon(Icons.tune_outlined, color: AppColors.neutral400, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChips(RecipeFilterState filterState) {
    final chips = [
      (RecipeFilter.halal, 'Halal', Icons.check_circle_outline, AppColors.tagHalal),
      (RecipeFilter.vegan, 'Vegan', Icons.eco, AppColors.tagVegan),
      (RecipeFilter.vegetarian, 'Vegetarian', Icons.spa, AppColors.tagVegetarian),
      (RecipeFilter.under30min, 'Under 30 min', Icons.timer_outlined, AppColors.neutral600),
      (RecipeFilter.myRecipes, 'My Recipes', Icons.person_outline, AppColors.secondary),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final (filter, label, icon, color) = chips[i];
          final isActive = filterState.activeFilters.contains(filter);
          return GestureDetector(
            onTap: () => ref.read(recipeFilterProvider.notifier).toggleFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isActive ? color : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isActive ? color : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: isActive ? AppColors.white : AppColors.neutral600),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: isActive ? AppColors.white : AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Sort Tabs ────────────────────────────────────────────────────────────

  Widget _buildSortTabs(RecipeFilterState filterState) {
    final tabs = [
      (RecipeSortOption.newest, 'Newest'),
      (RecipeSortOption.mostPopular, 'Most Popular'),
      (RecipeSortOption.lowestCalorie, 'Lowest Calorie'),
      (RecipeSortOption.quickest, 'Quickest'),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (_, i) {
          final (option, label) = tabs[i];
          final isActive = filterState.sortOption == option;
          return GestureDetector(
            onTap: () => ref.read(recipeFilterProvider.notifier).setSort(option),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.body2.copyWith(
                    color: isActive ? AppColors.primary : AppColors.neutral600,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 2,
                  width: isActive ? 100 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.neutral400),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No recipes found',
              style: AppTypography.headline2.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filters or search term.',
              style: AppTypography.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear filters',
                style: AppTypography.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
