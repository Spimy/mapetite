import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import 'step_progress_bar.dart';

/// Shared scaffold for all wizard steps.
/// Handles progress bar, scrollable body, and sticky footer layout.
class WizardScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? stepLabel;
  final Widget body;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool nextEnabled;
  final bool isNextLoading;
  final VoidCallback? onSkip;

  const WizardScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabel,
    required this.body,
    this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
    this.isNextLoading = false,
    this.onSkip,
  });

  // Intro step: no back button (full-width next, no skip shown).
  bool get _isIntroStep => onBack == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ).copyWith(top: AppSpacing.xxl, bottom: AppSpacing.xl),
                child: body,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontalPadding,
        AppSpacing.xxxl,
        AppSpacing.screenHorizontalPadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepProgressBar(totalSteps: totalSteps, currentStep: currentStep),
          if (stepLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                stepLabel!,
                style: AppTypography.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _isIntroStep ? _buildIntroFooter() : _buildStepFooter(),
        ),
      ),
    );
  }

  Widget _buildIntroFooter() {
    return AppButton(
      label: nextLabel,
      onPressed: nextEnabled ? onNext : null,
      isLoading: isNextLoading,
    );
  }

  Widget _buildStepFooter() {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back — pinned left
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Back',
              variant: AppButtonVariant.ghost,
              onPressed: onBack,
              isFullWidth: false,
            ),
          ),
          // Skip — always true-center
          if (onSkip != null)
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip for now',
                style:
                    AppTypography.body2.copyWith(color: AppColors.neutral400),
              ),
            ),
          // Next — pinned right
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: nextLabel,
              onPressed: nextEnabled ? onNext : null,
              isLoading: isNextLoading,
              isFullWidth: false,
              width: 120,
            ),
          ),
        ],
      ),
    );
  }
}
