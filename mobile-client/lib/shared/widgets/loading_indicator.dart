import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral100,
      highlightColor: AppColors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CardShimmer extends StatelessWidget {
  const CardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral100,
      highlightColor: AppColors.white,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSpacing.cardImageHeight,
              width: double.infinity,
              child: ColoredBox(color: AppColors.neutral100),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColoredBox(color: AppColors.neutral100, child: SizedBox(height: 16, width: 160)),
                  SizedBox(height: 8),
                  ColoredBox(color: AppColors.neutral100, child: SizedBox(height: 12, width: 100)),
                  SizedBox(height: 12),
                  ColoredBox(color: AppColors.neutral100, child: SizedBox(height: 12, width: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeFeedSkeleton extends StatelessWidget {
  const HomeFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral100,
      highlightColor: AppColors.white,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Greeting
            const _ShimmerBox(width: 200, height: 16),
            const SizedBox(height: AppSpacing.lg),
            // AI recommendation card
            const _ShimmerBox(width: double.infinity, height: 280),
            const SizedBox(height: AppSpacing.xxl),
            // Section header
            _buildSectionHeaderSkeleton(),
            const SizedBox(height: AppSpacing.md),
            // Restaurant card row
            _buildCardRowSkeleton(cardHeight: 220),
            const SizedBox(height: AppSpacing.xxl),
            // Section header
            _buildSectionHeaderSkeleton(),
            const SizedBox(height: AppSpacing.md),
            // Grocery card row
            _buildCardRowSkeleton(cardHeight: 160),
            const SizedBox(height: AppSpacing.xxl),
            // Section header
            _buildSectionHeaderSkeleton(),
            const SizedBox(height: AppSpacing.md),
            // Recipe card row
            _buildCardRowSkeleton(cardHeight: 220),
            const SizedBox(height: AppSpacing.xxl),
            // Budget card
            const _ShimmerBox(width: double.infinity, height: 100),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeaderSkeleton() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ShimmerBox(width: 160, height: 16),
        _ShimmerBox(width: 60, height: 14),
      ],
    );
  }

  Widget _buildCardRowSkeleton({required double cardHeight}) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, _) => _ShimmerBox(width: 160, height: cardHeight),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }
}
