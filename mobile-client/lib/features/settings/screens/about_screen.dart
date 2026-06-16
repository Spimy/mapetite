import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
        title: Text(
          'About',
          style: AppTypography.headline1.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildMissionCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildSdgSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildLegalSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildContactCard(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                'assets/logos/logo_icon.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mapetite',
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Your smart companion for a healthier, more connected urban lifestyle.',
              style: AppTypography.body1.copyWith(color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Version 1.0.0 (Build 42)',
            style: AppTypography.caption.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Mission', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mapetite aims to seamlessly integrate health, diet, and local exploration into the daily lives of urban professionals. We believe navigating the city\'s culinary landscape should be an empowering experience that supports your wellbeing.',
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildSdgSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Commitments', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        const _SdgCard(
          number: '3',
          color: AppColors.success,
          title: 'Good Health & Well-being',
          description:
              'Promoting healthy dietary choices and allergen-safe options.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SdgCard(
          number: '11',
          color: AppColors.warning,
          title: 'Sustainable Cities',
          description:
              'Supporting local businesses and walkable urban food discovery.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SdgCard(
          number: '12',
          color: AppColors.secondary,
          title: 'Responsible Consumption',
          description:
              'Mindful eating and better planning to reduce food waste.',
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _LegalRow(
                label: 'Terms of Service',
                isFirst: true,
                onTap: () => context.push('/about/terms'),
              ),
              const Divider(height: 1, color: AppColors.border, indent: AppSpacing.lg),
              _LegalRow(
                label: 'Privacy Policy',
                onTap: () => context.push('/about/privacy'),
              ),
              const Divider(height: 1, color: AppColors.border, indent: AppSpacing.lg),
              _LegalRow(
                label: 'Open Source Licences',
                isLast: true,
                onTap: () => context.push('/about/licences'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse('mailto:hello@mapetite.app');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outlined,
                  size: AppSpacing.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: AppTypography.label.copyWith(color: AppColors.neutral600),
                  ),
                  Text(
                    'hello@mapetite.app',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SdgCard extends StatelessWidget {
  final String number;
  final Color color;
  final String title;
  final String description;

  const _SdgCard({
    required this.number,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.avatarMd,
            height: AppSpacing.avatarMd,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.headline2.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headline3),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _LegalRow({
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(AppSpacing.radiusLg) : Radius.zero,
        bottom: isLast ? const Radius.circular(AppSpacing.radiusLg) : Radius.zero,
      ),
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: AppSpacing.iconSm,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
