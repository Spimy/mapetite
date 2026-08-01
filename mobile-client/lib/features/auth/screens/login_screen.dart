import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    ref.read(authControllerProvider.notifier).clearMessages();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      final authState = ref.read(authControllerProvider);

      if (authState.onboardingCompleted) {
        context.go('/home');
      } else {
        context.go('/profile/dietary');
      }
    }
  }

  Future<void> _onGoogleSignIn() async {
    ref.read(authControllerProvider.notifier).clearMessages();

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();
      if (account == null || !mounted) return; // user cancelled

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || !mounted) return;

      final success = await ref
          .read(authControllerProvider.notifier)
          .loginWithGoogle(idToken);

      if (!mounted || !success) return;

      final authState = ref.read(authControllerProvider);
      if (authState.onboardingCompleted) {
        context.go('/home');
      } else {
        context.go('/profile/dietary');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to sign in with Google. Please try again.',
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.white,
                    Color(0xFFECFDF5),
                  ],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.huge),
                    Center(
                      child: SvgPicture.asset(
                        'assets/logos/logo_wording.svg',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    Text(
                      'Welcome back',
                      style: AppTypography.headline1,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Sign in to your account.',
                      style: AppTypography.body2,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

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
                      validator: Validators.loginPassword,
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        errorMessage,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(
                            AppSpacing.touchTarget,
                            AppSpacing.touchTarget,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    AppButton(
                      label: 'Sign In',
                      onPressed: isLoading ? null : _onSignIn,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            'or continue with',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppButton(
                      label: 'Continue with Google',
                      variant: AppButtonVariant.outlined,
                      leadingIcon: Icons.g_mobiledata,
                      onPressed: isLoading ? null : _onGoogleSignIn,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.body2,
                        ),
                        TextButton(
                          onPressed:
                              isLoading ? null : () => context.go('/register'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, AppSpacing.touchTarget),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign up',
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
        ],
      ),
    );
  }
}