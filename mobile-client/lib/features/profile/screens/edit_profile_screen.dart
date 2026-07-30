import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/network_error_state.dart';
import '../controllers/profile_setup_controller.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/photo_picker_sheet.dart';
import '../widgets/unsaved_changes_dialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _usernameController;
  TextEditingController? _emailController;
  TextEditingController? _cityController;
  UserProfile? _initialProfile;
  bool _isSaving = false;

  void _ensureControllersInitialized(UserProfile profile) {
    if (_initialProfile != null) return;
    _initialProfile = profile;
    _usernameController = TextEditingController(text: profile.username)
      ..addListener(_onFieldChanged);
    _emailController = TextEditingController(text: profile.email);
    _cityController = TextEditingController(text: profile.city ?? '')
      ..addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _usernameController?.removeListener(_onFieldChanged);
    _cityController?.removeListener(_onFieldChanged);
    _usernameController?.dispose();
    _emailController?.dispose();
    _cityController?.dispose();
    super.dispose();
  }

  String _initials(String username) {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  String _dietarySummary(UserProfile p) {
    final parts = <String>[
      if (p.isHalal) 'Halal',
      if (p.isVegetarian) 'Vegetarian',
      if (p.isVegan) 'Vegan',
      ...p.allergens.map((a) => 'No $a'),
    ];
    return parts.isEmpty ? 'No restrictions' : parts.join(', ');
  }

  String _budgetSummary(UserProfile p) =>
      'RM ${p.monthlyBudget.toStringAsFixed(0)}/month';

  String _healthSummary(UserProfile p) {
    const labels = {
      'maintain_weight': 'Maintain Weight',
      'lose_weight': 'Lose Weight',
      'gain_muscle': 'Gain Muscle',
      'general_health': 'General Health',
    };
    return labels[p.healthGoal] ?? 'General Health';
  }

  Future<void> _navigateToDietary() async {
    final profile = ref.read(profileProvider).requireValue;
    ref.read(profileSetupControllerProvider.notifier).updateDietary(
      isHalal: profile.isHalal,
      isVegetarian: profile.isVegetarian,
      isVegan: profile.isVegan,
      allergens: List<String>.from(profile.allergens),
      dailyCalorieTarget: profile.dailyCalorieTarget,
      cuisinePreferences: List<String>.from(profile.cuisinePreferences),
    );
    await context.push('/profile/dietary?mode=edit');
    if (!mounted) return;
    final setup = ref.read(profileSetupControllerProvider);
    ref.read(profileProvider.notifier).updateDietary(
      isHalal: setup.isHalal,
      isVegetarian: setup.isVegetarian,
      isVegan: setup.isVegan,
      allergens: List<String>.from(setup.allergens),
      dailyCalorieTarget: setup.dailyCalorieTarget,
      cuisinePreferences: List<String>.from(setup.cuisinePreferences),
    );
  }

  Future<void> _navigateToBudget() async {
    final profile = ref.read(profileProvider).requireValue;
    ref.read(profileSetupControllerProvider.notifier).updateBudget(
      dineIn: profile.dineInBudget,
      grocery: profile.groceryBudget,
      alertThreshold: profile.alertThresholdPercent,
    );
    await context.push('/profile/budget-setup?mode=edit');
    if (!mounted) return;
    final setup = ref.read(profileSetupControllerProvider);
    ref.read(profileProvider.notifier).updateBudget(
      dineIn: setup.dineInBudget,
      grocery: setup.groceryBudget,
      alertThreshold: setup.alertThresholdPercent,
    );
  }

  Future<void> _navigateToHealth() async {
    final profile = ref.read(profileProvider).requireValue;
    ref.read(profileSetupControllerProvider.notifier).updateHealthGoals(
      healthGoal: profile.healthGoal,
      activityLevel: profile.activityLevel,
      weightKg: profile.weightKg,
    );
    await context.push('/profile/health-goals?mode=edit');
    if (!mounted) return;
    final setup = ref.read(profileSetupControllerProvider);
    ref.read(profileProvider.notifier).updateHealthGoals(
      healthGoal: setup.healthGoal,
      activityLevel: setup.activityLevel,
      weightKg: setup.weightKg,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(profileProvider.notifier)
      ..updateUsername(_usernameController!.text.trim())
      ..updateCity(_cityController!.text.trim());
    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).saveChanges();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  'Profile updated',
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
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your changes. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _hasUnsavedChanges(UserProfile current) {
    final initial = _initialProfile;
    if (initial == null) return false;
    return _usernameController!.text.trim() != initial.username ||
        _cityController!.text.trim() != (initial.city ?? '') ||
        current.isHalal != initial.isHalal ||
        current.isVegetarian != initial.isVegetarian ||
        current.isVegan != initial.isVegan ||
        !listEquals(current.allergens, initial.allergens) ||
        current.dailyCalorieTarget != initial.dailyCalorieTarget ||
        !listEquals(current.cuisinePreferences, initial.cuisinePreferences) ||
        current.dineInBudget != initial.dineInBudget ||
        current.groceryBudget != initial.groceryBudget ||
        current.alertThresholdPercent != initial.alertThresholdPercent ||
        current.healthGoal != initial.healthGoal ||
        current.activityLevel != initial.activityLevel ||
        current.weightKg != initial.weightKg;
  }

  void _handlePopAttempt() async {
    final discard = await showUnsavedChangesDialog(context);
    if (!discard || !mounted) return;
    ref.invalidate(profileProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.headline2.copyWith(color: AppColors.primary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Account & Preferences'),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is AppException && error.isNetworkError
            ? NetworkErrorState(onRetry: () => ref.invalidate(profileProvider))
            : AppEmptyState(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                description: 'Unable to load your profile. Please try again.',
                ctaLabel: 'Retry',
                onCta: () => ref.invalidate(profileProvider),
              ),
        data: (profile) {
          _ensureControllersInitialized(profile);
          final hasUnsaved = _hasUnsavedChanges(profile);

          return PopScope(
            canPop: !hasUnsaved,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _handlePopAttempt();
            },
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          _buildAvatarSection(profile),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildPersonalInfoSection(),
                          const SizedBox(height: AppSpacing.xxl),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildPreferencesSection(profile),
                          const SizedBox(height: AppSpacing.xxxl),
                          _buildDeleteButton(),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildStickyFooter(hasUnsaved),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(UserProfile profile) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: AppSpacing.avatarLg,
                height: AppSpacing.avatarLg,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(profile.username),
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => showPhotoPickerSheet(context),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => showPhotoPickerSheet(context),
            child: Text(
              'Change photo',
              style: AppTypography.body1.copyWith(
                color: AppColors.neutral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Username',
          controller: _usernameController,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username cannot be empty' : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildEmailField(),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Home Location',
          controller: _cityController,
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            size: AppSpacing.iconSm,
            color: AppColors.neutral400,
          ),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      controller: _emailController,
      readOnly: true,
      fillColor: AppColors.neutral100,
      suffixIcon: TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neutral,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Change',
          style: AppTypography.body1.copyWith(
            color: AppColors.neutral,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _PreferenceRow(
                icon: Icons.restaurant_outlined,
                label: 'Dietary Preferences',
                value: _dietarySummary(profile),
                onTap: _navigateToDietary,
                showDivider: true,
                isFirst: true,
              ),
              _PreferenceRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Budget Settings',
                value: _budgetSummary(profile),
                onTap: _navigateToBudget,
                showDivider: true,
              ),
              _PreferenceRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Health Goals',
                value: _healthSummary(profile),
                onTap: _navigateToHealth,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: GestureDetector(
        onTap: () => showDeleteAccountDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline,
                size: AppSpacing.iconXs,
                color: AppColors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Delete Account',
                style: AppTypography.body1.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyFooter(bool hasUnsaved) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: _isSaving ? 'Saving...' : 'Save Changes',
            isLoading: _isSaving,
            onPressed: (_isSaving || !hasUnsaved) ? null : _save,
          ),
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isFirst;

  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.showDivider,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isFirst
              ? const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                )
              : showDivider
                  ? BorderRadius.zero
                  : const BorderRadius.vertical(
                      bottom: Radius.circular(AppSpacing.radiusLg),
                    ),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: AppSpacing.iconSm,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(value, style: AppTypography.body2),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.neutral400,
                    size: AppSpacing.iconSm,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            color: AppColors.border,
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }
}
