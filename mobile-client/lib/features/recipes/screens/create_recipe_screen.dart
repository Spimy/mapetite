import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../profile/widgets/photo_picker_sheet.dart';
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

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _IngredientEntry {
  final nameCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  String unit = 'g';

  void dispose() {
    nameCtrl.dispose();
    quantityCtrl.dispose();
  }
}

class _StepEntry {
  final descCtrl = TextEditingController();

  void dispose() => descCtrl.dispose();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

  String? _selectedCuisine;

  final Set<String> _selectedTags = {};
  final List<_IngredientEntry> _ingredients = [
    _IngredientEntry(),
    _IngredientEntry(),
  ];
  final List<_StepEntry> _steps = [
    _StepEntry(),
    _StepEntry(),
  ];

  String? _ingredientsError;
  String? _stepsError;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prepTimeCtrl.dispose();
    _servingsCtrl.dispose();
    _caloriesCtrl.dispose();

    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }

    for (final step in _steps) {
      step.dispose();
    }

    super.dispose();
  }

  void _openPhotoPicker() {
    showPhotoPickerSheet(context);
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry());
      _ingredientsError = null;
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
    setState(() {
      _steps.add(_StepEntry());
      _stepsError = null;
    });
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) {
      return;
    }

    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
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
    final completedSteps = _steps
        .where((entry) => entry.descCtrl.text.trim().isNotEmpty)
        .toList();

    return completedSteps.asMap().entries.map((entry) {
      return RecipeStep(
        stepNumber: entry.key + 1,
        description: entry.value.descCtrl.text.trim(),
      );
    }).toList();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final ingredients = _buildIngredients();
    final steps = _buildSteps();

    setState(() {
      _ingredientsError =
          ingredients.isNotEmpty ? null : 'Add at least one ingredient';
      _stepsError = steps.isNotEmpty ? null : 'Add at least one step';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (ingredients.isEmpty || steps.isEmpty) {
      return;
    }

    final recipe = RecipeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      authorName: 'You',
      authorInitial: 'Y',
      cookMinutes: _parseIntOrDefault(_prepTimeCtrl.text, 0),
      calories: _parseIntOrDefault(_caloriesCtrl.text, 0),
      servings: _parseIntOrDefault(_servingsCtrl.text, 1),
      isHalal: _selectedTags.contains('Halal'),
      isVegan: _selectedTags.contains('Vegan'),
      isVegetarian: _selectedTags.contains('Vegetarian'),
      isGlutenFree: _selectedTags.contains('Gluten-Free'),
      cuisine: _selectedCuisine,
      ingredients: ingredients,
      steps: steps,
      visibility: RecipeVisibility.public,
      saves: 0,
      isOwnedByCurrentUser: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(recipeListProvider.notifier).addRecipe(recipe);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipe created!',
            style: AppTypography.body1.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/recipes');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorSnack(
        _errorMessageFrom(
          error,
          fallback: 'Unable to create recipe. Please try again.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageUpload(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTitleField(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDetailsRow(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCuisineDropdown(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDietaryTags(),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: AppSpacing.lg),
                      _buildIngredientsSection(),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: AppSpacing.lg),
                      _buildStepsSection(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              _buildStickyFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
        onPressed: _isSaving
            ? null
            : () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/recipes');
                }
              },
      ),
      title: Text('New Recipe', style: AppTypography.headline1),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => _save(),
          child: Text(
            _isSaving ? 'Saving...' : 'Save',
            style: AppTypography.body1.copyWith(
              color: _isSaving ? AppColors.neutral400 : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _isSaving ? null : _openPhotoPicker,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap to upload cover photo',
              style: AppTypography.body1.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      enabled: !_isSaving,
      style: AppTypography.body1,
      decoration: _inputDecoration('Recipe Title'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Recipe title is required';
        }

        return null;
      },
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildNumberField(_prepTimeCtrl, 'Prep Time', 'min'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildNumberField(_servingsCtrl, 'Servings', ''),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildNumberField(_caloriesCtrl, 'Calories', 'opt'),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    TextEditingController ctrl,
    String label,
    String suffix,
  ) {
    return TextFormField(
      controller: ctrl,
      enabled: !_isSaving,
      keyboardType: TextInputType.number,
      style: AppTypography.body1,
      decoration: _inputDecoration(label).copyWith(
        suffixText: suffix.isNotEmpty ? suffix : null,
        suffixStyle: AppTypography.label.copyWith(
          color: AppColors.neutral600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.body2.copyWith(color: AppColors.neutral600),
      floatingLabelStyle: AppTypography.label.copyWith(
        color: AppColors.primary,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }


  Widget _buildCuisineDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCuisine,
      isExpanded: true,
      decoration: _inputDecoration('Cuisine'),
      hint: Text(
        'Select cuisine',
        style: AppTypography.body1.copyWith(color: AppColors.neutral400),
      ),
      items: _cuisineOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label, style: AppTypography.body1),
        );
      }).toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() {
                _selectedCuisine = value;
              });
            },
    );
  }

  Widget _buildDietaryTags() {
    const tags = [
      ('Halal', AppColors.tagHalal),
      ('Vegan', AppColors.tagVegan),
      ('Vegetarian', AppColors.tagVegetarian),
      ('Gluten-Free', AppColors.tagAllergen),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dietary Tags', style: AppTypography.headline3),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tags.map((tag) {
            final isSelected = _selectedTags.contains(tag.$1);

            return GestureDetector(
              onTap: _isSaving
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag.$1);
                        } else {
                          _selectedTags.add(tag.$1);
                        }
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? tag.$2 : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isSelected ? tag.$2 : AppColors.border,
                  ),
                ),
                child: Text(
                  tag.$1,
                  style: AppTypography.label.copyWith(
                    color: isSelected ? AppColors.white : AppColors.neutral600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(
          _ingredients.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _IngredientRowWidget(
              entry: _ingredients[i],
              enabled: !_isSaving,
              onDelete: _ingredients.length > 1 && !_isSaving
                  ? () => _removeIngredient(i)
                  : null,
            ),
          ),
        ),
        if (_ingredientsError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _ingredientsError!,
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        _AddRowButton(
          label: 'Add ingredient',
          onTap: _isSaving ? null : _addIngredient,
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(
          _steps.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _StepRowWidget(
              entry: _steps[i],
              enabled: !_isSaving,
              stepNumber: i + 1,
              onDelete:
                  _steps.length > 1 && !_isSaving ? () => _removeStep(i) : null,
            ),
          ),
        ),
        if (_stepsError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _stepsError!,
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        _AddRowButton(
          label: 'Add step',
          onTap: _isSaving ? null : _addStep,
        ),
      ],
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: _isSaving ? 'Saving...' : 'Save Recipe',
          onPressed: _isSaving ? () {} : () => _save(),
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

  const _IngredientRowWidget({
    required this.entry,
    required this.enabled,
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
          child: _CompactField(
            controller: widget.entry.nameCtrl,
            hint: 'Ingredient',
            enabled: widget.enabled,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 64,
          child: _CompactField(
            controller: widget.entry.quantityCtrl,
            hint: 'Qty',
            enabled: widget.enabled,
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
  final _StepEntry entry;
  final bool enabled;
  final int stepNumber;
  final VoidCallback? onDelete;

  const _StepRowWidget({
    required this.entry,
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
          child: TextField(
            controller: entry.descCtrl,
            enabled: enabled,
            maxLines: 2,
            style: AppTypography.body1,
            decoration: InputDecoration(
              hintText: 'Describe this step...',
              hintStyle: AppTypography.body1.copyWith(
                color: AppColors.neutral400,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
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

// ─── Compact Field ────────────────────────────────────────────────────────────

class _CompactField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType? keyboardType;

  const _CompactField({
    required this.controller,
    required this.hint,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: AppTypography.body1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body1.copyWith(
            color: AppColors.neutral400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}

// ─── Add Row Button ───────────────────────────────────────────────────────────

class _AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _AddRowButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: isEnabled ? AppColors.primary : AppColors.neutral400,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: isEnabled ? AppColors.primary : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}