import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(filteredRecipesProvider);
    final filterState = ref.watch(recipeFilterProvider);
    final activeFilterCount = filterState.activeFilters.length +
        filterState.activeCuisines.length +
        filterState.allergenFreeFilters.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildSearchBar(filterState, activeFilterCount)),
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
                        mainAxisExtent: 280,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: _RecipeScreenBottomNav(),
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
      title: Row(
        children: [
          Builder(
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
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Recipes',
              style: AppTypography.headline2.copyWith(color: AppColors.primary),
            ),
          ),
          GestureDetector(
            onTap: _openAddSheet,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(RecipeFilterState filterState, int activeFilterCount) {
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
              : _FilterIconButton(
                  count: activeFilterCount,
                  onTap: _openFilterSheet,
                ),
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
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        children: _chipDefinitions().map((def) {
          final isActive = filterState.activeFilters.contains(def.filter);
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => ref.read(recipeFilterProvider.notifier).toggleFilter(def.filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isActive ? def.activeColor : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isActive ? def.activeColor : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChipIcon(def, isActive),
                    const SizedBox(width: 4),
                    Text(
                      def.label,
                      style: AppTypography.label.copyWith(
                        color: isActive ? AppColors.white : AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChipIcon(_ChipDef def, bool isActive) {
    if (def.filter == RecipeFilter.halal) {
      return SvgPicture.asset(
        'assets/icons/dietary/halal-icon.svg',
        width: 13,
        height: 13,
        colorFilter: ColorFilter.mode(
          isActive ? AppColors.white : AppColors.neutral600,
          BlendMode.srcIn,
        ),
      );
    }
    return Icon(
      def.icon,
      size: 13,
      color: isActive ? AppColors.white : AppColors.neutral600,
    );
  }

  List<_ChipDef> _chipDefinitions() => [
        const _ChipDef(RecipeFilter.halal, 'Halal', Icons.check_circle_outline, AppColors.tagHalal),
        const _ChipDef(RecipeFilter.vegan, 'Vegan', Icons.eco, AppColors.tagVegan),
        const _ChipDef(RecipeFilter.vegetarian, 'Vegetarian', Icons.spa, AppColors.tagVegetarian),
        const _ChipDef(RecipeFilter.under30min, 'Under 30 min', Icons.timer_outlined, AppColors.neutral600),
        const _ChipDef(RecipeFilter.saved, 'Saved', Icons.bookmark_outline, AppColors.primary),
        const _ChipDef(RecipeFilter.myRecipes, 'My Recipes', Icons.person_outline, AppColors.secondary),
      ];

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

// ─── Filter Icon Button (with badge) ─────────────────────────────────────────

class _FilterIconButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FilterIconButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: count > 0 ? AppColors.primary : AppColors.neutral400,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
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

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterProvider);
    final notifier = ref.read(recipeFilterProvider.notifier);
    final hasActiveFilters = filterState.activeFilters.isNotEmpty ||
        filterState.activeCuisines.isNotEmpty ||
        filterState.allergenFreeFilters.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Recipes', style: AppTypography.headline2),
                      if (hasActiveFilters)
                        GestureDetector(
                          onTap: notifier.clearFilters,
                          child: Text(
                            'Clear all',
                            style: AppTypography.body2.copyWith(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cuisine', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _CuisineIconGrid(
                      activeOptions: filterState.activeCuisines,
                      onToggle: notifier.toggleCuisine,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Dietary', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _FilterChipGroup(
                      filters: const [RecipeFilter.halal, RecipeFilter.vegan, RecipeFilter.vegetarian],
                      labels: const ['Halal', 'Vegan', 'Vegetarian'],
                      activeFilters: filterState.activeFilters,
                      onToggle: notifier.toggleFilter,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Time', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _FilterChipGroup(
                      filters: const [RecipeFilter.under30min],
                      labels: const ['Under 30 min'],
                      activeFilters: filterState.activeFilters,
                      onToggle: notifier.toggleFilter,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Allergen-free (Free from)', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _StringChipGroup(
                      options: AppConstants.allergenOptions,
                      activeOptions: filterState.allergenFreeFilters,
                      onToggle: notifier.toggleAllergenFree,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Collections', style: AppTypography.headline3.copyWith(color: AppColors.neutral600)),
                    const SizedBox(height: AppSpacing.sm),
                    _FilterChipGroup(
                      filters: const [RecipeFilter.saved, RecipeFilter.myRecipes],
                      labels: const ['Saved', 'My Recipes'],
                      activeFilters: filterState.activeFilters,
                      onToggle: notifier.toggleFilter,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Apply Filters', style: AppTypography.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipGroup extends StatelessWidget {
  final List<RecipeFilter> filters;
  final List<String> labels;
  final Set<RecipeFilter> activeFilters;
  final ValueChanged<RecipeFilter> onToggle;

  const _FilterChipGroup({
    required this.filters,
    required this.labels,
    required this.activeFilters,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(filters.length, (i) {
        final filter = filters[i];
        final label = labels[i];
        final isActive = activeFilters.contains(filter);
        return GestureDetector(
          onTap: () => onToggle(filter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.neutral600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Cuisine Icon Grid ────────────────────────────────────────────────────────

class _CuisineIconGrid extends StatelessWidget {
  final Set<String> activeOptions;
  final ValueChanged<String> onToggle;

  static const Map<String, IconData> _icons = {
    'Malaysian': Icons.rice_bowl,
    'Chinese': Icons.ramen_dining,
    'Indian': Icons.soup_kitchen,
    'Japanese': Icons.set_meal,
    'Western': Icons.lunch_dining,
    'Thai': Icons.local_fire_department,
    'Korean': Icons.outdoor_grill,
    'Middle Eastern': Icons.kebab_dining,
  };

  const _CuisineIconGrid({
    required this.activeOptions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const totalSpacing = (columns - 1) * AppSpacing.sm;
        final chipWidth = (constraints.maxWidth - totalSpacing) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: AppConstants.cuisineCategories.map((cuisine) {
            final isActive = activeOptions.contains(cuisine);
            final icon = _icons[cuisine] ?? Icons.restaurant;
            return GestureDetector(
              onTap: () => onToggle(cuisine),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: chipWidth,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                  horizontal: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryLight : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isActive ? AppColors.primary : AppColors.neutral600,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      cuisine,
                      style: AppTypography.caption.copyWith(
                        color: isActive ? AppColors.primary : AppColors.neutral600,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── String Chip Group (for cuisine / allergen-free filters) ─────────────────

class _StringChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> activeOptions;
  final ValueChanged<String> onToggle;

  const _StringChipGroup({
    required this.options,
    required this.activeOptions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isActive = activeOptions.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Text(
              option,
              style: AppTypography.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.neutral600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Chip Definition Helper ───────────────────────────────────────────────────

class _ChipDef {
  final RecipeFilter filter;
  final String label;
  final IconData icon;
  final Color activeColor;

  const _ChipDef(this.filter, this.label, this.icon, this.activeColor);
}

// ─── Empty State ──────────────────────────────────────────────────────────────

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

// ─── Persistent Bottom Nav ────────────────────────────────────────────────────

class _RecipeScreenBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/explore');
            case 2:
              context.go('/map');
            case 3:
              context.go('/budget');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}
