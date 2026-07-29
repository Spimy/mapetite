import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Uri _resetPasswordUri() {
    final apiBase = Uri.parse(AppConfig.baseUrl);
    return apiBase.replace(path: '/reset-password/');
  }

  Future<bool> _launchResetPage() async {
    try {
      return await launchUrl(
        _resetPasswordUri(),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _onSendResetLink() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final launched = await _launchResetPage();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (launched) {
        _emailSent = true;
      } else {
        _errorMessage = 'Could not open the reset page. Please try again.';
      }
    });

    if (launched) {
      _startResendCountdown();
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendCountdown <= 1) {
        _resendTimer?.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _onResendEmail() async {
    final launched = await _launchResetPage();
    if (!mounted) return;

    if (launched) {
      _startResendCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the reset page. Please try again.'),
        ),
      );
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _emailSent
              ? _buildSuccessState()
              : _buildInputState(),
        ),
      ),
    );
  }

  Widget _buildInputState() {
    return SingleChildScrollView(
      key: const ValueKey('input'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text('Reset your password', style: AppTypography.headline1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter the email address linked to your account and we will send you a link.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              validator: Validators.email,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _errorMessage!,
                style: AppTypography.body2.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Send Reset Link',
              onPressed: _onSendResetLink,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    final bool canResend = _resendCountdown == 0;

    return SingleChildScrollView(
      key: const ValueKey('success'),
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
                Icons.email_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Check your email',
            style: AppTypography.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'We\'ve opened the reset page in your browser.',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: canResend
                ? 'Resend email'
                : 'Resend in ${_resendCountdown}s',
            variant: AppButtonVariant.outlined,
            onPressed: canResend ? _onResendEmail : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Back to Sign In',
            variant: AppButtonVariant.ghost,
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
