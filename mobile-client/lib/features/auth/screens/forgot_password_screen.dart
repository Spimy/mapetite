import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Uri _resetPasswordUri() {
    final apiBase = Uri.parse(AppConfig.baseUrl);
    return apiBase.replace(path: '/reset-password/');
  }

  Future<void> _onResetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool launched;
    try {
      launched = await launchUrl(
        _resetPasswordUri(),
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage =
          launched ? null : 'Could not open the reset page. Please try again.';
    });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text('Reset your password', style: AppTypography.headline1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'ll open the reset page in your browser, where you can '
                'enter your email and set a new password.',
                style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _errorMessage!,
                  style: AppTypography.body2.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Reset Password',
                onPressed: _onResetPassword,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
