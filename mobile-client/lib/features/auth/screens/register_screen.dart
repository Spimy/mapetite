import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/password_strength_bar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  bool _termsAccepted = false;
  String _passwordValue = '';
  bool _verificationSent = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password1: _passwordController.text,
          password2: _confirmPasswordController.text,
        );

    if (success && mounted) {
      // Logic for after successful registration
      setState(() {
        _verificationSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen for error messages and show a SnackBar when they change immediately.
    // This ensures that the user sees the error message as soon as it occurs.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        final messenger = ScaffoldMessenger.of(context);

        messenger.clearSnackBars();

        messenger.showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _verificationSent
          ? null
          : AppBar(
              backgroundColor: AppColors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
                onPressed: () => context.go('/login'),
              ),
            ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _verificationSent
              // Pass the dynamic detail message here
              ? _buildVerificationState(
                  authState.successMessage ??
                      'A verification email has been sent.',
                )
              // Pass the loading state to disable fields/buttons
              : _buildFormState(authState.isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create account', style: AppTypography.headline1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Join Mapetite and start eating smart.',
              style: AppTypography.body2,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Username',
              controller: _usernameController,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, field: 'Username'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              enabled: !isLoading,
              validator: Validators.password,
              onChanged: (value) => setState(() => _passwordValue = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            PasswordStrengthBar(password: _passwordValue),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Confirm password',
              controller: _confirmPasswordController,
              obscureText: true,
              enabled: !isLoading,
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordController.text),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Home location (suburb)',
              controller: _locationController,
              enabled: !isLoading,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTermsRow(isLoading),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Create Account',
              onPressed: _termsAccepted ? _onCreateAccount : null,
              isLoading: isLoading,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: AppTypography.body2),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, AppSpacing.touchTarget),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Log in',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationState(String? successMessage) {
    final String email = _emailController.text.trim();

    return SingleChildScrollView(
      key: const ValueKey('verify'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
      ),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Verify your email',
            style: AppTypography.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            successMessage ??
                'We sent a verification link to $email. Click the link in your email to activate your account, then sign in.',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Go to Sign In',
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildTermsRow(bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.touchTarget,
          height: AppSpacing.touchTarget,
          child: Checkbox(
            value: _termsAccepted,
            activeColor: AppColors.primary,
            onChanged: isLoading
                ? null
                : (v) => setState(() => _termsAccepted = v ?? false),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: AppTypography.body2,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms of Service',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
