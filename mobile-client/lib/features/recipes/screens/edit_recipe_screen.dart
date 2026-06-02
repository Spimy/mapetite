import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_chip.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class _IngredientEntry {
  final TextEditingController nameCtrl;
  final TextEditingController quantityCtrl;
  final TextEditingController storeCtrl;
  final TextEditingController priceCtrl;

  _IngredientEntry()
      : nameCtrl = TextEditingController(),
        quantityCtrl = TextEditingController(),
        storeCtrl = TextEditingController(),
        priceCtrl = TextEditingController();

  _IngredientEntry.from(RecipeIngredient ing)
      : nameCtrl = TextEditingController(text: ing.name),
        quantityCtrl = TextEditingController(text: ing.quantity),
        storeCtrl = TextEditingController(text: ing.storeName ?? ''),
        priceCtrl = TextEditingController(
          text: ing.estimatedCost != null ? ing.estimatedCost!.toStringAsFixed(2) : '',
        );

  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
    storeCtrl.dispose();
    priceCtrl.dispose();
  }
}

class EditRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _cookTimeCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _caloriesCtrl;

  late List<_IngredientEntry> _ingredients;
  late List<TextEditingController> _stepControllers;

  late bool _isHalal;
  late bool _isVegan;
  late bool _isVegetarian;
  late String? _cuisine;
  late Set<String> _selectedAllergens;
  late RecipeVisibility _visibility;

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;

    _titleCtrl = TextEditingController(text: r.title);
    _descCtrl = TextEditingController(text: r.description ?? '');
    _cookTimeCtrl = TextEditingController(text: r.cookMinutes.toString());
    _servingsCtrl = TextEditingController(text: r.servings.toString());
    _caloriesCtrl = TextEditingController(text: r.calories > 0 ? r.calories.toString() : '');

    _ingredients = r.ingredients.isEmpty
        ? [_IngredientEntry()]
        : r.ingredients.map((ing) => _IngredientEntry.from(ing)).toList();

    _stepControllers = r.steps.isEmpty
        ? [TextEditingController()]
        : r.steps.map((s) => TextEditingController(text: s.description)).toList();

    _isHalal = r.isHalal;
    _isVegan = r.isVegan;
    _isVegetarian = r.isVegetarian;
    _cuisine = r.cuisine;
    _selectedAllergens = Set<String>.from(r.allergens);
    _visibility = r.visibility;

    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _cookTimeCtrl.dispose();
    _servingsCtrl.dispose();
    _caloriesCtrl.dispose();
    for (final e in _ingredients) e.dispose();
    for (final c in _stepControllers) c.dispose();
    super.dispose();
  }

  void _addIngredient() => setState(() => _ingredients.add(_IngredientEntry()));

  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) return;
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() => setState(() => _stepControllers.add(TextEditingController()));

  void _removeStep(int index) {
    if (_stepControllers.length <= 1) return;
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  void _save() {
    final cookMins = int.tryParse(_cookTimeCtrl.text.trim()) ?? widget.recipe.cookMinutes;
    final servings = int.tryParse(_servingsCtrl.text.trim()) ?? widget.recipe.servings;
    final calories = int.tryParse(_caloriesCtrl.text.trim()) ?? widget.recipe.calories;

    final ingredients = _ingredients.asMap().entries.map((e) {
      final ing = e.value;
      return RecipeIngredient(
        name: ing.nameCtrl.text.trim().isEmpty ? 'Ingredient ${e.key + 1}' : ing.nameCtrl.text.trim(),
        quantity: ing.quantityCtrl.text.trim().isEmpty ? '1' : ing.quantityCtrl.text.trim(),
        storeName: ing.storeCtrl.text.trim().isEmpty ? null : ing.storeCtrl.text.trim(),
        estimatedCost: double.tryParse(ing.priceCtrl.text.trim()),
      );
    }).toList();

    final steps = _stepControllers.asMap().entries.map((e) {
      return RecipeStep(
        stepNumber: e.key + 1,
        description: e.value.text.trim().isEmpty ? 'Step ${e.key + 1}' : e.value.text.trim(),
      );
    }).toList();

    final updated = RecipeModel(
      id: widget.recipe.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      authorName: widget.recipe.authorName,
      authorInitial: widget.recipe.authorInitial,
      cookMinutes: cookMins,
      calories: calories,
      servings: servings,
      isHalal: _isHalal,
      isVegan: _isVegan,
      isVegetarian: _isVegetarian,
      cuisine: _cuisine,
      allergens: List<String>.from(_selectedAllergens),
      ingredients: ingredients,
      steps: steps,
      visibility: _visibility,
      saves: widget.recipe.saves,
      isOwnedByCurrentUser: true,
      createdAt: widget.recipe.createdAt,
    );

    ref.read(recipeListProvider.notifier).updateRecipe(updated);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Recipe updated!',
                style: AppTypography.body1.copyWith(color: AppColors.white),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 14),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            elevation: 2,
            scrolledUnderElevation: 2,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.neutral),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Edit Recipe', style: AppTypography.headline2),
            actions: [
              TextButton(
                onPressed: _canSave ? _save : null,
                child: Text(
                  'Save',
                  style: AppTypography.button.copyWith(
                    color: _canSave ? AppColors.primary : AppColors.neutral400,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Recipe Title'),
                  const SizedBox(height: AppSpacing.sm),
                  _EditTextField(controller: _titleCtrl, hint: 'e.g. Nasi Lemak with Sambal'),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Description'),
                  const SizedBox(height: AppSpacing.sm),
                  _EditTextField(
                    controller: _descCtrl,
                    hint: 'Brief description of your recipe...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('Cook Time (min)'),
                            const SizedBox(height: AppSpacing.sm),
                            _EditTextField(
                              controller: _cookTimeCtrl,
                              hint: '30',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('Servings'),
                            const SizedBox(height: AppSpacing.sm),
                            _EditTextField(
                              controller: _servingsCtrl,
                              hint: '2',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Total Calories (kcal)'),
                  const SizedBox(height: AppSpacing.sm),
                  _EditTextField(
                    controller: _caloriesCtrl,
                    hint: 'e.g. 450',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Cuisine'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AppConstants.cuisineCategories.map((c) {
                      final isSelected = _cuisine == c;
                      return GestureDetector(
                        onTap: () => setState(() => _cuisine = isSelected ? null : c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.neutral200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppConstants.cuisineIcons[c] ?? Icons.restaurant_menu,
                                size: 13,
                                color: isSelected ? AppColors.white : AppColors.neutral600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                c,
                                style: AppTypography.label.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Dietary Tags'),
                  const SizedBox(height: AppSpacing.sm),
                  _DietaryTagRow(
                    isHalal: _isHalal,
                    isVegan: _isVegan,
                    isVegetarian: _isVegetarian,
                    onHalalChanged: (v) => setState(() => _isHalal = v),
                    onVeganChanged: (v) => setState(() => _isVegan = v),
                    onVegetarianChanged: (v) => setState(() => _isVegetarian = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Allergens (This recipe contains)'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AppConstants.allergenOptions.map((a) {
                      final isSelected = _selectedAllergens.contains(a);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedAllergens.remove(a);
                          } else {
                            _selectedAllergens.add(a);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.warning.withValues(alpha: 0.15)
                                : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isSelected ? AppColors.warning : AppColors.neutral200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppChip.allergenIconMap[a] ?? Icons.warning_amber,
                                size: 13,
                                color: isSelected ? AppColors.warning : AppColors.neutral600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a,
                                style: AppTypography.label.copyWith(
                                  color: isSelected ? AppColors.warning : AppColors.neutral600,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Ingredients'),
                  const SizedBox(height: AppSpacing.sm),
                  ..._ingredients.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ing = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _EditTextField(
                                  controller: ing.nameCtrl,
                                  hint: 'e.g. Cooked rice',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 2,
                                child: _EditTextField(
                                  controller: ing.quantityCtrl,
                                  hint: 'Qty',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: () => _removeIngredient(i),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _EditTextField(
                                  controller: ing.storeCtrl,
                                  hint: 'Store (optional)',
                                  prefixIcon: Icons.storefront_outlined,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                flex: 2,
                                child: _EditTextField(
                                  controller: ing.priceCtrl,
                                  hint: 'Est. RM',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  prefixIcon: Icons.attach_money_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  _AddFieldButton(label: 'Add Ingredient', onTap: _addIngredient),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Steps'),
                  const SizedBox(height: AppSpacing.sm),
                  ..._stepControllers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ctrl = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(top: 10, right: AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: AppTypography.label.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _EditTextField(
                              controller: ctrl,
                              hint: 'Describe step ${i + 1}...',
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => _removeStep(i),
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 18,
                                color: AppColors.neutral600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  _AddFieldButton(label: 'Add Step', onTap: _addStep),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel('Visibility'),
                  const SizedBox(height: AppSpacing.sm),
                  _VisibilityToggle(
                    value: _visibility,
                    onChanged: (v) => setState(() => _visibility = v),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _canSave ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.neutral200,
                        disabledForegroundColor: AppColors.neutral400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Save Changes', style: AppTypography.button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.headline3.copyWith(color: AppColors.neutral),
    );
  }
}

class _EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _EditTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.body1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 16, color: AppColors.neutral400)
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? AppSpacing.xs : AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _DietaryTagRow extends StatelessWidget {
  final bool isHalal;
  final bool isVegan;
  final bool isVegetarian;
  final ValueChanged<bool> onHalalChanged;
  final ValueChanged<bool> onVeganChanged;
  final ValueChanged<bool> onVegetarianChanged;

  const _DietaryTagRow({
    required this.isHalal,
    required this.isVegan,
    required this.isVegetarian,
    required this.onHalalChanged,
    required this.onVeganChanged,
    required this.onVegetarianChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _TagToggle(
          label: 'Halal',
          svgAsset: 'assets/icons/dietary/halal-icon.svg',
          isActive: isHalal,
          activeColor: AppColors.tagHalal,
          onToggle: () => onHalalChanged(!isHalal),
        ),
        _TagToggle(
          label: 'Vegan',
          icon: Icons.eco,
          isActive: isVegan,
          activeColor: AppColors.tagVegan,
          onToggle: () => onVeganChanged(!isVegan),
        ),
        _TagToggle(
          label: 'Vegetarian',
          icon: Icons.spa,
          isActive: isVegetarian,
          activeColor: AppColors.tagVegetarian,
          onToggle: () => onVegetarianChanged(!isVegetarian),
        ),
      ],
    );
  }
}

class _TagToggle extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgAsset;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onToggle;

  const _TagToggle({
    required this.label,
    this.icon,
    this.svgAsset,
    required this.isActive,
    required this.activeColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? AppColors.white : AppColors.neutral600;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isActive ? activeColor : AppColors.neutral200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, size: 13, color: iconColor),
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
  }
}

class _VisibilityToggle extends StatelessWidget {
  final RecipeVisibility value;
  final ValueChanged<RecipeVisibility> onChanged;

  const _VisibilityToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VisibilityOption(
            icon: Icons.public,
            label: 'Public',
            subtitle: 'Everyone can see',
            isSelected: value == RecipeVisibility.public,
            onTap: () => onChanged(RecipeVisibility.public),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _VisibilityOption(
            icon: Icons.lock_outline,
            label: 'Private',
            subtitle: 'Only you can see',
            isSelected: value == RecipeVisibility.private,
            onTap: () => onChanged(RecipeVisibility.private),
          ),
        ),
      ],
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.neutral600,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.headline3.copyWith(
                color: isSelected ? AppColors.primary : AppColors.neutral,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFieldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddFieldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
