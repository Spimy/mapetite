import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../profile/widgets/photo_picker_sheet.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
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

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

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

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prepTimeCtrl.dispose();
    _servingsCtrl.dispose();
    _caloriesCtrl.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    for (final s in _steps) {
      s.dispose();
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
    if (_ingredients.length <= 1) return;
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
    if (_steps.length <= 1) return;
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
  }

  void _save() {
    final hasIngredient = _ingredients.any((i) => i.nameCtrl.text.trim().isNotEmpty);
    final hasStep = _steps.any((s) => s.descCtrl.text.trim().isNotEmpty);

    setState(() {
      _ingredientsError = hasIngredient ? null : 'Add at least one ingredient';
      _stepsError = hasStep ? null : 'Add at least one step';
    });

    if (!_formKey.currentState!.validate()) return;
    if (!hasIngredient || !hasStep) return;

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/recipes');
    }
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
        onPressed: () {
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
          onPressed: _save,
          child: Text(
            'Save',
            style: AppTypography.body1.copyWith(
              color: AppColors.primary,
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
      onTap: _openPhotoPicker,
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
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      style: AppTypography.body1,
      decoration: _inputDecoration('Recipe Title'),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Recipe title is required' : null,
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
      keyboardType: TextInputType.number,
      style: AppTypography.body1,
      decoration: _inputDecoration(label).copyWith(
        suffixText: suffix.isNotEmpty ? suffix : null,
        suffixStyle: AppTypography.label.copyWith(color: AppColors.neutral600),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.body2.copyWith(color: AppColors.neutral600),
      floatingLabelStyle: AppTypography.label.copyWith(color: AppColors.primary),
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
              onTap: () {
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
              onDelete: _ingredients.length > 1
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
        _AddRowButton(label: 'Add ingredient', onTap: _addIngredient),
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
              stepNumber: i + 1,
              onDelete: _steps.length > 1 ? () => _removeStep(i) : null,
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
        _AddRowButton(label: 'Add step', onTap: _addStep),
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
        child: AppButton(label: 'Save Recipe', onPressed: _save),
      ),
    );
  }
}

// ─── Ingredient Row ───────────────────────────────────────────────────────────

class _IngredientRowWidget extends StatefulWidget {
  final _IngredientEntry entry;
  final VoidCallback? onDelete;

  const _IngredientRowWidget({required this.entry, this.onDelete});

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
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 64,
          child: _CompactField(
            controller: widget.entry.quantityCtrl,
            hint: 'Qty',
            keyboardType: TextInputType.number,
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
                    (u) => DropdownMenuItem(
                      value: u,
                      child: Text(u, style: AppTypography.body2),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => widget.entry.unit = v);
              },
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
  final int stepNumber;
  final VoidCallback? onDelete;

  const _StepRowWidget({
    required this.entry,
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
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
  final TextInputType? keyboardType;

  const _CompactField({
    required this.controller,
    required this.hint,
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
        keyboardType: keyboardType,
        style: AppTypography.body1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body1.copyWith(color: AppColors.neutral400),
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
  final VoidCallback onTap;

  const _AddRowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.add, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
