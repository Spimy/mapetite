import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/recipe_model.dart';

class AddRecipeSheet extends StatefulWidget {
  const AddRecipeSheet({super.key});

  @override
  State<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<AddRecipeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  bool _isHalal = false;
  bool _isVegan = false;
  bool _isVegetarian = false;
  RecipeVisibility _visibility = RecipeVisibility.public;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() => _ingredientControllers.add(TextEditingController()));
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length <= 1) return;
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStepField() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStepField(int index) {
    if (_stepControllers.length <= 1) return;
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recipe "${_titleController.text}" submitted!',
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
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add New Recipe', style: AppTypography.headline2),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.neutral600),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImageUploadArea(),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel('Recipe Title'),
                        const SizedBox(height: AppSpacing.sm),
                        _SheetTextField(
                          controller: _titleController,
                          hint: 'e.g. Nasi Lemak with Sambal',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel('Description'),
                        const SizedBox(height: AppSpacing.sm),
                        _SheetTextField(
                          controller: _descController,
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
                                  _SheetTextField(
                                    controller: _cookTimeController,
                                    hint: '30',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
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
                                  _SheetTextField(
                                    controller: _servingsController,
                                    hint: '2',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                        const _SectionLabel('Ingredients'),
                        const SizedBox(height: AppSpacing.sm),
                        ..._ingredientControllers.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ctrl = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _SheetTextField(
                                    controller: ctrl,
                                    hint: 'e.g. 2 cups cooked rice',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: () => _removeIngredientField(i),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    ),
                                    child: const Icon(Icons.remove, size: 18, color: AppColors.neutral600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        _AddFieldButton(
                          label: 'Add Ingredient',
                          onTap: _addIngredientField,
                        ),
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
                                  child: _SheetTextField(
                                    controller: ctrl,
                                    hint: 'Describe step ${i + 1}...',
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: () => _removeStepField(i),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    ),
                                    child: const Icon(Icons.remove, size: 18, color: AppColors.neutral600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        _AddFieldButton(
                          label: 'Add Step',
                          onTap: _addStepField,
                        ),
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
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              elevation: 0,
                            ),
                            child: Text('Submit Recipe', style: AppTypography.button),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageUploadArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.neutral200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.neutral400),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap to add a photo',
              style: AppTypography.body2.copyWith(color: AppColors.neutral600),
            ),
          ],
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
          icon: Icons.check_circle_outline,
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
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onToggle;

  const _TagToggle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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
        fillColor: AppColors.neutral100,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
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
