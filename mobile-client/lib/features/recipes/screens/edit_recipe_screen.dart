import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/widgets/unsaved_changes_dialog.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

const _cuisineOptions = <({String value, String label})>[
  (value: 'MAMAK', label: 'Mamak'),
  (value: 'NASI_KANDAR', label: 'Nasi Kandar'),
  (value: 'MALAYSIAN', label: 'Malaysian'),
  (value: 'KOPITIAM', label: 'Kopitiam'),
  (value: 'CHINESE', label: 'Chinese'),
  (value: 'JAPANESE', label: 'Japanese'),
  (value: 'KOREAN', label: 'Korean'),
  (value: 'FUSION', label: 'Fusion'),
  (value: 'INDONESIAN', label: 'Indonesian'),
  (value: 'MEXICAN', label: 'Mexican'),
  (value: 'MEDITERRANEAN', label: 'Mediterranean'),
  (value: 'HEALTHY', label: 'Healthy'),
];

String? _normaliseCuisineValue(String? value) {
  final raw = value?.trim();

  if (raw == null || raw.isEmpty) {
    return null;
  }

  var cleaned = raw
      .replaceAll(r'\"', '"')
      .replaceAll(r"\'", "'")
      .replaceAll('\\', '')
      .trim();

  while (cleaned.length >= 2 &&
      ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
          (cleaned.startsWith("'") && cleaned.endsWith("'")))) {
    cleaned = cleaned.substring(1, cleaned.length - 1).trim();
  }

  final normalised = cleaned.toUpperCase().replaceAll(' ', '_');

  for (final option in _cuisineOptions) {
    if (option.value == normalised ||
        option.label.toUpperCase().replaceAll(' ', '_') == normalised) {
      return option.value;
    }
  }

  return null;
}

class _IngredientEntry {
  final TextEditingController nameCtrl;
  final TextEditingController quantityCtrl;
  String unit;

  _IngredientEntry()
      : nameCtrl = TextEditingController(),
        quantityCtrl = TextEditingController(),
        unit = 'g';

  _IngredientEntry.from(RecipeIngredient ingredient)
      : nameCtrl = TextEditingController(text: ingredient.name),
        quantityCtrl = TextEditingController(
          text: _displayQuantity(ingredient),
        ),
        unit = ingredient.unit ?? 'g';

  void addListener(VoidCallback listener) {
    nameCtrl.addListener(listener);
    quantityCtrl.addListener(listener);
  }

  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
  }
}

class EditRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _cookTimeCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _caloriesCtrl;

  String? _selectedCuisine;

  late List<_IngredientEntry> _ingredients;
  late List<TextEditingController> _stepControllers;

  late bool _isHalal;
  late bool _isVegan;
  late bool _isVegetarian;
  late bool _isGlutenFree;

  bool _isSaving = false;
  bool _isDeleting = false;

  bool get _hasChanges {
    final recipe = widget.recipe;

    if (_titleCtrl.text.trim() != recipe.title) {
      return true;
    }

    if (_cookTimeCtrl.text.trim() != recipe.cookMinutes.toString()) {
      return true;
    }

    if (_servingsCtrl.text.trim() != recipe.servings.toString()) {
      return true;
    }

    final originalCalories = recipe.calories > 0 ? recipe.calories.toString() : '';

    if (_caloriesCtrl.text.trim() != originalCalories) {
      return true;
    }

    if (_selectedCuisine != _normaliseCuisineValue(recipe.cuisine)) {
      return true;
    }

    if (_isHalal != recipe.isHalal) {
      return true;
    }

    if (_isVegan != recipe.isVegan) {
      return true;
    }

    if (_isVegetarian != recipe.isVegetarian) {
      return true;
    }

    if (_isGlutenFree != recipe.isGlutenFree) {
      return true;
    }

    if (_ingredients.length != recipe.ingredients.length) {
      return true;
    }

    for (var i = 0; i < _ingredients.length; i++) {
      final original = recipe.ingredients[i];
      final current = _ingredients[i];

      if (current.nameCtrl.text.trim() != original.name) {
        return true;
      }

      if (current.quantityCtrl.text.trim() != _displayQuantity(original)) {
        return true;
      }

      if (current.unit != (original.unit ?? 'g')) {
        return true;
      }
    }

    if (_stepControllers.length != recipe.steps.length) {
      return true;
    }

    for (var i = 0; i < _stepControllers.length; i++) {
      if (_stepControllers[i].text.trim() != recipe.steps[i].description) {
        return true;
      }
    }

    return false;
  }

  bool get _canSave {
    return !_isSaving &&
        !_isDeleting &&
        _hasChanges &&
        _titleCtrl.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    final recipe = widget.recipe;

    _titleCtrl = TextEditingController(text: recipe.title);
    _cookTimeCtrl = TextEditingController(text: recipe.cookMinutes.toString());
    _servingsCtrl = TextEditingController(text: recipe.servings.toString());
    _caloriesCtrl = TextEditingController(
      text: recipe.calories > 0 ? recipe.calories.toString() : '',
    );
    _selectedCuisine = _normaliseCuisineValue(recipe.cuisine);

    _ingredients = recipe.ingredients.isEmpty
        ? [_IngredientEntry()]
        : recipe.ingredients.map(_IngredientEntry.from).toList();

    _stepControllers = recipe.steps.isEmpty
        ? [TextEditingController()]
        : recipe.steps
            .map((step) => TextEditingController(text: step.description))
            .toList();

    _isHalal = recipe.isHalal;
    _isVegan = recipe.isVegan;
    _isVegetarian = recipe.isVegetarian;
    _isGlutenFree = recipe.isGlutenFree;

    for (final controller in [
      _titleCtrl,
      _cookTimeCtrl,
      _servingsCtrl,
      _caloriesCtrl,
    ]) {
      controller.addListener(_onChanged);
    }

    for (final ingredient in _ingredients) {
      ingredient.addListener(_onChanged);
    }

    for (final controller in _stepControllers) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _cookTimeCtrl.dispose();
    _servingsCtrl.dispose();
    _caloriesCtrl.dispose();

    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }

    for (final controller in _stepControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addIngredient() {
    final entry = _IngredientEntry();
    entry.addListener(_onChanged);

    setState(() {
      _ingredients.add(entry);
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) {
      return;
    }

    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    final controller = TextEditingController();
    controller.addListener(_onChanged);

    setState(() {
      _stepControllers.add(controller);
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length <= 1) {
      return;
    }

    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  Future<void> _handlePopAttempt() async {
    if (_isSaving || _isDeleting) {
      return;
    }

    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final discard = await showUnsavedChangesDialog(context);

    if (discard && mounted) {
      Navigator.of(context).pop();
    }
  }

  int _parseIntOrDefault(String value, int fallback) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  List<RecipeIngredient> _buildIngredients() {
    return _ingredients
        .where((entry) => entry.nameCtrl.text.trim().isNotEmpty)
        .map(
          (entry) => RecipeIngredient(
            name: entry.nameCtrl.text.trim(),
            quantity: entry.quantityCtrl.text.trim().isEmpty
                ? '1'
                : entry.quantityCtrl.text.trim(),
            unit: entry.unit,
          ),
        )
        .toList();
  }

  List<RecipeStep> _buildSteps() {
    final completedSteps = _stepControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .toList();

    return completedSteps.asMap().entries.map((entry) {
      return RecipeStep(
        stepNumber: entry.key + 1,
        description: entry.value.text.trim(),
      );
    }).toList();
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    final ingredients = _buildIngredients();
    final steps = _buildSteps();

    if (ingredients.isEmpty) {
      _showErrorSnack('Add at least one ingredient.');
      return;
    }

    if (steps.isEmpty) {
      _showErrorSnack('Add at least one step.');
      return;
    }

    final updated = widget.recipe.copyWith(
      title: _titleCtrl.text.trim(),
      cookMinutes: _parseIntOrDefault(
        _cookTimeCtrl.text,
        widget.recipe.cookMinutes,
      ),
      servings: _parseIntOrDefault(
        _servingsCtrl.text,
        widget.recipe.servings,
      ),
      calories: _parseIntOrDefault(
        _caloriesCtrl.text,
        widget.recipe.calories,
      ),
      cuisine: _selectedCuisine,
      isHalal: _isHalal,
      isVegan: _isVegan,
      isVegetarian: _isVegetarian,
      isGlutenFree: _isGlutenFree,
      ingredients: ingredients,
      steps: steps,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(recipeListProvider.notifier).updateRecipe(updated);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipe updated!',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorSnack(
        _errorMessageFrom(
          error,
          fallback: 'Unable to update recipe. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteRecipe() async {
    if (_isSaving || _isDeleting) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete recipe?', style: AppTypography.headline2),
          content: Text(
            'This recipe will be permanently deleted.',
            style: AppTypography.body1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(recipeListProvider.notifier).deleteRecipe(widget.recipe.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipe deleted.',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );

      context.go('/recipes');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorSnack(
        _errorMessageFrom(
          error,
          fallback: 'Unable to delete recipe. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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


  String _errorMessageFrom(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final message = _extractApiError(error.response?.data);

      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }

  String? _extractApiError(dynamic data, {String? field}) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      return field == null ? data : '$field: $data';
    }

    if (data is List) {
      final messages = <String>[];

      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final itemField = field == null ? null : '$field ${i + 1}';
        final nested = _extractApiError(item, field: itemField);

        if (nested != null && nested.isNotEmpty) {
          messages.add(nested);
        }
      }

      return messages.isEmpty ? null : messages.join('\n');
    }

    if (data is Map) {
      final messages = <String>[];

      for (final entry in data.entries) {
        final fieldName = _formatApiFieldName(entry.key.toString());
        final nextField = field == null ? fieldName : '$field $fieldName';
        final nested = _extractApiError(entry.value, field: nextField);

        if (nested != null && nested.isNotEmpty) {
          messages.add(nested);
        }
      }

      return messages.isEmpty ? null : messages.join('\n');
    }

    return null;
  }

  String _formatApiFieldName(String value) {
    if (value == 'non_field_errors') {
      return 'Error';
    }

    final words = value.replaceAll('_', ' ');

    if (words.isEmpty) {
      return 'Error';
    }

    return words[0].toUpperCase() + words.substring(1);
  }

  Widget _buildCuisineDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCuisine,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Select cuisine',
        hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: _cuisineOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label, style: AppTypography.body1),
        );
      }).toList(),
      onChanged: _isSaving || _isDeleting
          ? null
          : (value) {
              setState(() {
                _selectedCuisine = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges && !_isSaving && !_isDeleting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handlePopAttempt();
        }
      },
      child: Scaffold(
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
                onPressed:
                    _isSaving || _isDeleting ? null : _handlePopAttempt,
              ),
              title: Text('Edit Recipe', style: AppTypography.headline2),
              actions: [
                TextButton(
                  onPressed: _canSave ? _save : null,
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save',
                    style: AppTypography.body1.copyWith(
                      color:
                          _canSave ? AppColors.primary : AppColors.neutral400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Recipe Title'),
                    const SizedBox(height: AppSpacing.sm),
                    _EditTextField(
                      controller: _titleCtrl,
                      enabled: !_isSaving && !_isDeleting,
                      hint: 'e.g. Nasi Lemak with Sambal',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel('Prep Time (min)'),
                              const SizedBox(height: AppSpacing.sm),
                              _EditTextField(
                                controller: _cookTimeCtrl,
                                enabled: !_isSaving && !_isDeleting,
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
                                enabled: !_isSaving && !_isDeleting,
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
                      enabled: !_isSaving && !_isDeleting,
                      hint: 'e.g. 450',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Cuisine'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCuisineDropdown(),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Dietary Tags'),
                    const SizedBox(height: AppSpacing.sm),
                    _DietaryTagRow(
                      enabled: !_isSaving && !_isDeleting,
                      isHalal: _isHalal,
                      isVegan: _isVegan,
                      isVegetarian: _isVegetarian,
                      isGlutenFree: _isGlutenFree,
                      onHalalChanged: (value) {
                        setState(() {
                          _isHalal = value;
                        });
                      },
                      onVeganChanged: (value) {
                        setState(() {
                          _isVegan = value;
                        });
                      },
                      onVegetarianChanged: (value) {
                        setState(() {
                          _isVegetarian = value;
                        });
                      },
                      onGlutenFreeChanged: (value) {
                        setState(() {
                          _isGlutenFree = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Ingredients'),
                    const SizedBox(height: AppSpacing.sm),
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _IngredientRowWidget(
                          entry: ingredient,
                          enabled: !_isSaving && !_isDeleting,
                          onDelete: _ingredients.length > 1 &&
                                  !_isSaving &&
                                  !_isDeleting
                              ? () => _removeIngredient(index)
                              : null,
                          onChanged: () => setState(() {}),
                        ),
                      );
                    }),
                    _AddFieldButton(
                      label: 'Add Ingredient',
                      onTap:
                          _isSaving || _isDeleting ? null : _addIngredient,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('Steps'),
                    const SizedBox(height: AppSpacing.sm),
                    ..._stepControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _StepRowWidget(
                          controller: controller,
                          enabled: !_isSaving && !_isDeleting,
                          stepNumber: index + 1,
                          onDelete: _stepControllers.length > 1 &&
                                  !_isSaving &&
                                  !_isDeleting
                              ? () => _removeStep(index)
                              : null,
                        ),
                      );
                    }),
                    _AddFieldButton(
                      label: 'Add Step',
                      onTap: _isSaving || _isDeleting ? null : _addStep,
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
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: AppTypography.button,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed:
                            _isSaving || _isDeleting ? null : _deleteRecipe,
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                        label: Text(
                          _isDeleting ? 'Deleting...' : 'Delete Recipe',
                          style: AppTypography.button.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ingredient Row ───────────────────────────────────────────────────────────

class _IngredientRowWidget extends StatefulWidget {
  final _IngredientEntry entry;
  final bool enabled;
  final VoidCallback? onDelete;
  final VoidCallback onChanged;

  const _IngredientRowWidget({
    required this.entry,
    required this.enabled,
    required this.onChanged,
    this.onDelete,
  });

  @override
  State<_IngredientRowWidget> createState() => _IngredientRowWidgetState();
}

class _IngredientRowWidgetState extends State<_IngredientRowWidget> {
  static const _units = ['g', 'kg', 'ml', 'L', 'pcs', 'tbsp', 'tsp', 'cup'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _EditTextField(
            controller: widget.entry.nameCtrl,
            enabled: widget.enabled,
            hint: 'Ingredient',
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 70,
          child: _EditTextField(
            controller: widget.entry.quantityCtrl,
            enabled: widget.enabled,
            hint: 'Qty',
            keyboardType: TextInputType.text,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 76,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.entry.unit,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 16),
              style: AppTypography.body2.copyWith(color: AppColors.neutral),
              items: _units
                  .map(
                    (unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit, style: AppTypography.body2),
                    ),
                  )
                  .toList(),
              onChanged: widget.enabled
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          widget.entry.unit = value;
                        });
                        widget.onChanged();
                      }
                    }
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          onPressed: widget.onDelete,
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: widget.onDelete != null
                ? AppColors.error
                : AppColors.neutral200,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
        ),
      ],
    );
  }
}

// ─── Step Row ─────────────────────────────────────────────────────────────────

class _StepRowWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final int stepNumber;
  final VoidCallback? onDelete;

  const _StepRowWidget({
    required this.controller,
    required this.enabled,
    required this.stepNumber,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: AppTypography.label.copyWith(color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _EditTextField(
            controller: controller,
            enabled: enabled,
            hint: 'Describe step $stepNumber...',
            maxLines: 2,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: onDelete != null ? AppColors.error : AppColors.neutral200,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

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
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;

  const _EditTextField({
    required this.controller,
    required this.hint,
    required this.enabled,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTypography.body1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _DietaryTagRow extends StatelessWidget {
  final bool enabled;
  final bool isHalal;
  final bool isVegan;
  final bool isVegetarian;
  final bool isGlutenFree;
  final ValueChanged<bool> onHalalChanged;
  final ValueChanged<bool> onVeganChanged;
  final ValueChanged<bool> onVegetarianChanged;
  final ValueChanged<bool> onGlutenFreeChanged;

  const _DietaryTagRow({
    required this.enabled,
    required this.isHalal,
    required this.isVegan,
    required this.isVegetarian,
    required this.isGlutenFree,
    required this.onHalalChanged,
    required this.onVeganChanged,
    required this.onVegetarianChanged,
    required this.onGlutenFreeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _TagToggle(
          label: 'Halal',
          icon: Icons.check_circle_outline,
          isActive: isHalal,
          activeColor: AppColors.tagHalal,
          enabled: enabled,
          onToggle: () => onHalalChanged(!isHalal),
        ),
        _TagToggle(
          label: 'Vegan',
          icon: Icons.eco,
          isActive: isVegan,
          activeColor: AppColors.tagVegan,
          enabled: enabled,
          onToggle: () => onVeganChanged(!isVegan),
        ),
        _TagToggle(
          label: 'Vegetarian',
          icon: Icons.spa,
          isActive: isVegetarian,
          activeColor: AppColors.tagVegetarian,
          enabled: enabled,
          onToggle: () => onVegetarianChanged(!isVegetarian),
        ),
        _TagToggle(
          label: 'Gluten-Free',
          icon: Icons.no_food_outlined,
          isActive: isGlutenFree,
          activeColor: AppColors.tagAllergen,
          enabled: enabled,
          onToggle: () => onGlutenFreeChanged(!isGlutenFree),
        ),
      ],
    );
  }
}

class _TagToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final bool enabled;
  final VoidCallback onToggle;

  const _TagToggle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onToggle : null,
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
            Icon(
              icon,
              size: 13,
              color: isActive ? AppColors.white : AppColors.neutral600,
            ),
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

class _AddFieldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _AddFieldButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primaryLight : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: isEnabled ? AppColors.primary : AppColors.neutral400,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: isEnabled ? AppColors.primary : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _displayQuantity(RecipeIngredient ingredient) {
  final unit = ingredient.unit;

  if (unit == null || unit.isEmpty) {
    return ingredient.quantity;
  }

  final suffix = ' $unit';

  if (ingredient.quantity.endsWith(suffix)) {
    return ingredient.quantity.substring(
      0,
      ingredient.quantity.length - suffix.length,
    );
  }

  return ingredient.quantity;
}