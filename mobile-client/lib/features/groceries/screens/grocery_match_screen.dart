import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/custom_button.dart';

class GroceryMatchScreen extends StatelessWidget {
  final String recipeId;

  const GroceryMatchScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeSummaryCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildBestMatchSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildOtherStoresSection(context),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/recipes/$recipeId');
          }
        },
      ),
      title: Text(
        'Find Ingredients',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildRecipeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: AppSpacing.avatarXl,
              height: AppSpacing.avatarXl,
              color: AppColors.primaryLight,
              child: const Icon(
                Icons.restaurant_menu,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nasi Goreng Kampung',
                  style: AppTypography.headline2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Requires 6 specific ingredients.',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppChip.halal(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestMatchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, size: 20, color: AppColors.success),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Best Match',
              style: AppTypography.headline3.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jaya Grocer', style: AppTypography.headline2),
                  Text(
                    'RM 7.20',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '0.8 km away',
                    style: AppTypography.body2,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items Available',
                    style: AppTypography.label.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    '6 / 6 (100%)',
                    style: AppTypography.label.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 10,
                  backgroundColor: AppColors.neutral100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'View Store & Add to List',
                onPressed: () => context.push('/groceries/jaya-grocer'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherStoresSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Nearby Stores',
          style: AppTypography.headline3.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: AppSpacing.sm),
        _OtherStoreCard(
          name: '99 Speedmart',
          estimatedCost: 'RM 4.80',
          distance: '0.5 km away',
          availableCount: 4,
          totalCount: 6,
          coverage: 0.67,
          coverageColor: AppColors.warning,
          coverageLabel: '4 / 6 (67%)',
          onTap: () => context.push('/groceries/99-speedmart'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _OtherStoreCard(
          name: 'Village Grocer',
          estimatedCost: 'RM 6.50',
          distance: '2.1 km away',
          availableCount: 5,
          totalCount: 6,
          coverage: 0.83,
          coverageColor: AppColors.primary,
          coverageLabel: '5 / 6 (83%)',
          onTap: () => context.push('/groceries/village-grocer'),
        ),
      ],
    );
  }
}

// ─── Other Store Card ─────────────────────────────────────────────────────────

class _OtherStoreCard extends StatelessWidget {
  final String name;
  final String estimatedCost;
  final String distance;
  final int availableCount;
  final int totalCount;
  final double coverage;
  final Color coverageColor;
  final String coverageLabel;
  final VoidCallback onTap;

  const _OtherStoreCard({
    required this.name,
    required this.estimatedCost,
    required this.distance,
    required this.availableCount,
    required this.totalCount,
    required this.coverage,
    required this.coverageColor,
    required this.coverageLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTypography.headline3),
                Text(estimatedCost, style: AppTypography.headline3),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(distance, style: AppTypography.body2),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items Available',
                  style: AppTypography.label.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  coverageLabel,
                  style: AppTypography.label.copyWith(
                    color: coverageColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: LinearProgressIndicator(
                value: coverage,
                minHeight: 10,
                backgroundColor: AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation<Color>(coverageColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
