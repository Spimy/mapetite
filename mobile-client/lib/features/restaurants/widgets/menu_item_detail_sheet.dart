import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/models/store_item_model.dart';

class MenuItemDetailSheet extends StatefulWidget {
  final StoreItemModel item;

  const MenuItemDetailSheet({super.key, required this.item});

  @override
  State<MenuItemDetailSheet> createState() => _MenuItemDetailSheetState();
}

class _MenuItemDetailSheetState extends State<MenuItemDetailSheet> {
  bool _restrictionsExpanded = false;

  StoreItemModel get _item => widget.item;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.lg),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                _buildImage(),
                _buildBody(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
      child: SizedBox(
        height: AppSpacing.cardImageHeight,
        width: double.infinity,
        child: _item.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: _item.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const CardShimmer(),
                errorWidget: (_, _, _) => _PlaceholderImage(),
              )
            : _PlaceholderImage(),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name
          Text(_item.name, style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.xs),
          // Description
          Text(
            _item.description,
            style: AppTypography.body1.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.md),
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'RM ${_item.price.toStringAsFixed(2)}',
                style: AppTypography.price.copyWith(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'excl. tax',
                style: AppTypography.caption,
              ),
            ],
          ),
          // Dietary chips
          if (_item.dietaryTags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _item.dietaryTags
                  .map((tag) => _dietaryChipForTag(tag))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          // Restrictions collapsible
          if (_item.restrictions.isNotEmpty) _buildRestrictionsSection(),
        ],
      ),
    );
  }

  Widget _buildRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _restrictionsExpanded = !_restrictionsExpanded),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Restrictions', style: AppTypography.headline3),
                AnimatedRotation(
                  turns: _restrictionsExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _restrictionsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _item.restrictions
                  .map((r) => DietaryChip.restriction(r))
                  .toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _dietaryChipForTag(String tag) {
    return switch (tag) {
      'Halal' => const DietaryChip.halal(),
      'Vegan' => const DietaryChip.vegan(),
      'Vegetarian' => const DietaryChip.vegetarian(),
      _ => DietaryChip.allergen(tag),
    };
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral100,
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 48, color: AppColors.neutral400),
      ),
    );
  }
}
