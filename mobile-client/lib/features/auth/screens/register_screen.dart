import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/password_strength_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  bool _termsAccepted = false;
  String _passwordValue = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Replace with real auth service
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  label: 'Full name',
                  controller: _nameController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, field: 'Full name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Home location (suburb)',
                  controller: _locationController,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.neutral400,
                  ),
                  // TODO: Replace with Google Places autocomplete
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTermsRow(),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Create Account',
                  onPressed: _termsAccepted ? _onCreateAccount : null,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body2,
                    ),
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
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSpacing.touchTarget,
          height: AppSpacing.touchTarget,
          child: Checkbox(
            value: _termsAccepted,
            activeColor: AppColors.primary,
            onChanged: _isLoading
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
