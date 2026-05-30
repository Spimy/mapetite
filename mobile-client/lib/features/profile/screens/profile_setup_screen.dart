import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/services/setup_service.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/profile_setup_controller.dart';
import '../widgets/wizard_scaffold.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillFromRegistration();
  }

  Future<void> _prefillFromRegistration() async {
    final info = await SetupService.getPendingUserInfo();
    if (info != null && mounted) {
      _nameController.text = info.name;
      _emailController.text = info.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(profileSetupControllerProvider.notifier).updateIntroFields(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
    context.go('/profile/dietary');
  }

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      currentStep: 0,
      totalSteps: 4,
      stepLabel: 'Step 1 of 4',
      onNext: _onNext,
      nextLabel: 'Next',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's get started.", style: AppTypography.display),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We need a few details to personalise your smart city experience.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Full Name',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, field: 'Full Name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pre-filled from your registration details.',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
