import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/onboarding_slide.dart';

class _SlideData {
  final String step;
  final String headline;
  final String body;
  final String imagePath;
  final IconData badgeIcon;

  const _SlideData({
    required this.step,
    required this.headline,
    required this.body,
    required this.imagePath,
    required this.badgeIcon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_SlideData> _slides = [
    _SlideData(
      step: 'Step 01',
      headline: 'Discover food near you.',
      body:
          'Find halal restaurants, grocery stores, and recipes within walking distance of where you are right now.',
      imagePath: 'assets/images/onboarding1.png',
      badgeIcon: Icons.search_rounded,
    ),
    _SlideData(
      step: 'Step 02',
      headline: 'Stay on budget, every meal.',
      body:
          'Set a monthly food budget and Mapetite tracks every meal automatically using your location.',
      imagePath: 'assets/images/onboarding2.png',
      badgeIcon: Icons.account_balance_wallet_outlined,
    ),
    _SlideData(
      step: 'Step 03',
      headline: 'AI picks matched to you.',
      body:
          'Get personalised restaurant and recipe suggestions based on your diet, budget, and how far you want to travel.',
      imagePath: 'assets/images/onboarding3.png',
      badgeIcon: Icons.auto_awesome,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: AppConstants.animNormal),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    step: slide.step,
                    headline: slide.headline,
                    body: slide.body,
                    imagePath: slide.imagePath,
                    badgeIcon: slide.badgeIcon,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalPadding,
                AppSpacing.md,
                AppSpacing.screenHorizontalPadding,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => _buildDot(i),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: isLast ? 'Get started' : 'Next',
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.animNormal),
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.neutral200,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}
