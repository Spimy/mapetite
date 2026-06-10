import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../recipes/providers/selected_ingredients_provider.dart';

class GroceryMatchScreen extends ConsumerWidget {
  final String recipeId;

  const GroceryMatchScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedIngredientsProvider);
    final itemCount = selectedItems.length;
    final totalCost =
        selectedItems.fold(0.0, (sum, i) => sum + i.cost);

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
              _buildSelectedItemsCard(selectedItems),
              const SizedBox(height: AppSpacing.lg),
              _buildBestMatchSection(context, itemCount, totalCost),
              const SizedBox(height: AppSpacing.lg),
              _buildOtherStoresSection(context, itemCount),
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
        'Find Grocery Store',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildSelectedItemsCard(
      List<SelectedIngredient> items) {
    return Container(
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
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Shopping for ${items.length} ingredient${items.length != 1 ? 's' : ''}',
                style: AppTypography.headline3,
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 6, color: AppColors.neutral400),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${item.name}  ·  ${item.quantity}',
                        style: AppTypography.body2
                            .copyWith(color: AppColors.neutral600),
                      ),
                    ),
                    if (item.cost > 0)
                      Text(
                        'RM ${item.cost.toStringAsFixed(2)}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.neutral600),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBestMatchSection(
      BuildContext context, int itemCount, double totalCost) {
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
                  if (totalCost > 0)
                    Text(
                      'est. RM ${totalCost.toStringAsFixed(2)}',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.neutral400),
                  SizedBox(width: AppSpacing.xxs),
                  Text('0.8 km away'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items Available',
                    style: AppTypography.label
                        .copyWith(color: AppColors.neutral600),
                  ),
                  Text(
                    '$itemCount / $itemCount (100%)',
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'View Store Details',
                onPressed: () => context.push('/groceries/jaya-grocer'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherStoresSection(BuildContext context, int itemCount) {
    final partial67 = (itemCount * 0.67).round().clamp(0, itemCount);
    final partial83 = (itemCount * 0.83).round().clamp(0, itemCount);
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
          distance: '0.5 km away',
          availableCount: partial67,
          totalCount: itemCount,
          coverage: 0.67,
          coverageColor: AppColors.warning,
          onTap: () => context.push('/groceries/99-speedmart'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _OtherStoreCard(
          name: 'Village Grocer',
          distance: '2.1 km away',
          availableCount: partial83,
          totalCount: itemCount,
          coverage: 0.83,
          coverageColor: AppColors.primary,
          onTap: () => context.push('/groceries/village-grocer'),
        ),
      ],
    );
  }
}

// ─── Other Store Card ─────────────────────────────────────────────────────────

class _OtherStoreCard extends StatelessWidget {
  final String name;
  final String distance;
  final int availableCount;
  final int totalCount;
  final double coverage;
  final Color coverageColor;
  final VoidCallback onTap;

  const _OtherStoreCard({
    required this.name,
    required this.distance,
    required this.availableCount,
    required this.totalCount,
    required this.coverage,
    required this.coverageColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (coverage * 100).round();
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
            Text(name, style: AppTypography.headline3),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: AppColors.neutral400),
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
                  style: AppTypography.label
                      .copyWith(color: AppColors.neutral600),
                ),
                Text(
                  '$availableCount / $totalCount ($pct%)',
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
