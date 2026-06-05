import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/dietary_chip.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../models/mocks/restaurant_mocks.dart';
import '../models/restaurant_model.dart';
import '../widgets/menu_item_detail_sheet.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  int _activeMenuTab = 0;
  final List<String> _menuTabs = ['All', 'Mains', 'Sides', 'Beverages'];

  RestaurantModel get _restaurant {
    return RestaurantMocks.nearbyRestaurants.firstWhere(
      (r) => r.id == widget.restaurantId,
      orElse: () => RestaurantMocks.nearbyRestaurants.first,
    );
  }

  List<MenuItem> get _filteredItems {
    final tab = _menuTabs[_activeMenuTab];
    if (tab == 'All') return _restaurant.menuItems;
    return _restaurant.menuItems.where((i) => i.category == tab).toList();
  }

  void _openDirections() {
    final lat = _restaurant.lat;
    final lng = _restaurant.lng;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening Google Maps to ($lat, $lng)',
          style: AppTypography.body2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _restaurant;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context, r),
                  _buildBodyCard(r),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, RestaurantModel r) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: AppSpacing.heroImageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          r.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: r.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.primaryLight),
                  errorWidget: (_, _, _) =>
                      const ColoredBox(color: AppColors.primaryLight),
                )
              : Container(
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          // Back button
          Positioned(
            top: topPadding + AppSpacing.sm,
            left: AppSpacing.lg,
            child: _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
              tooltip: 'Back',
            ),
          ),
          // Share button
          Positioned(
            top: topPadding + AppSpacing.sm,
            right: AppSpacing.lg,
            child: _CircleButton(
              icon: Icons.share_outlined,
              onTap: () {},
              tooltip: 'Share',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyCard(RestaurantModel r) {
    return Transform.translate(
      offset: const Offset(0, -AppSpacing.lg),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(r),
            _buildInfoRows(r),
            _buildWhyWePickedCard(r),
            _buildMenuSection(r),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            style: AppTypography.headline1,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            r.cuisineType,
            style: AppTypography.body2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (r.dietaryTags.contains('Halal'))
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: DietaryChip.halal(),
                ),
              PricingBadge(bracket: r.pricingBracket),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRows(RestaurantModel r) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            child: Text(r.address, style: AppTypography.body1),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.schedule,
            iconColor: AppColors.success,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: r.isOpen ? 'Open' : 'Closed',
                    style: AppTypography.body1.copyWith(
                      color: r.isOpen ? AppColors.success : AppColors.error,
                    ),
                  ),
                  if (r.isOpen)
                    TextSpan(
                      text: ' · Closes ${r.closingTime}',
                      style: AppTypography.body1,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.phone_outlined,
            child: Text(r.phone, style: AppTypography.body1),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyWePickedCard(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.thumb_up,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Why we picked this', style: AppTypography.headline3),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _ReasonChip(icon: Icons.near_me, label: 'Proximity'),
                _ReasonChip(icon: Icons.restaurant, label: 'Diet Match'),
                _ReasonChip(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget Fit',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(RestaurantModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu', style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.md),
          _buildMenuTabs(),
          const SizedBox(height: AppSpacing.md),
          _buildMenuItems(),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'See all ${r.menuItems.length} items',
                style: AppTypography.body2.copyWith(
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildMenuTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _menuTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isActive = index == _activeMenuTab;
          return GestureDetector(
            onTap: () => setState(() => _activeMenuTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                _menuTabs[index],
                style: AppTypography.label.copyWith(
                  color: isActive ? AppColors.white : AppColors.neutral,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItems() {
    final items = _filteredItems;
    return Column(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return _MenuItemRow(
          item: entry.value,
          showDivider: !isLast,
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => MenuItemDetailSheet(item: entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickyFooter() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Get Directions',
              leadingIcon: Icons.directions,
              onPressed: _openDirections,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Opens Google Maps',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _InfoRow({
    required this.icon,
    this.iconColor = AppColors.neutral600,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: iconColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: child),
      ],
    );
  }
}

// ── Reason Chip ───────────────────────────────────────────────────────────────

class _ReasonChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReasonChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral600),
          const SizedBox(width: AppSpacing.xxs + 2),
          Text(
            label,
            style: AppTypography.body2.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}

// ── Menu Item Row ─────────────────────────────────────────────────────────────

class _MenuItemRow extends StatelessWidget {
  final MenuItem item;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuItemRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.headline3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.description,
                        style: AppTypography.body2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'RM ${item.price.toStringAsFixed(2)}',
                  style: AppTypography.headline3,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

// ── Circle Button ─────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: AppSpacing.iconSm, color: AppColors.neutral),
        ),
      ),
    );
  }
}
