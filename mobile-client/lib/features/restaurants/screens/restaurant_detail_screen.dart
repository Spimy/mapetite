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

  RestaurantModel get _restaurant => RestaurantMocks.nearbyRestaurants
      .firstWhere(
        (r) => r.id == widget.restaurantId,
        orElse: () => RestaurantMocks.nearbyRestaurants.first,
      );

  List<MenuItem> get _filteredItems {
    final tab = _menuTabs[_activeMenuTab];
    if (tab == 'All') return _restaurant.menuItems;
    return _restaurant.menuItems.where((i) => i.category == tab).toList();
  }

  bool get _isShowingAll =>
      _filteredItems.length == _restaurant.menuItems.length;

  void _openShareSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _RestaurantShareSheet(restaurant: _restaurant),
    );
  }

  void _openDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Opening Google Maps to ${_restaurant.name}',
                style: AppTypography.body1.copyWith(color: AppColors.white),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 14),
            ),
          ],
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
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context, r),
                  _buildBodyCard(r),
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
      height: AppSpacing.heroImageHeight + topPadding,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
          // Back button — positioned below status bar
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
              onTap: _openShareSheet,
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
            _buildWhyWePickedCard(),
            _buildMenuSection(r),
            const SizedBox(height: AppSpacing.xxl),
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
          Text(r.cuisineType, style: AppTypography.body2),
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

  Widget _buildWhyWePickedCard() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 18, color: AppColors.primary),
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
          _MenuTabRow(
            tabs: _menuTabs,
            activeIndex: _activeMenuTab,
            onChanged: (i) => setState(() => _activeMenuTab = i),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMenuItems(),
          // Only show "see all" when a category filter hides some items
          if (!_isShowingAll) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _activeMenuTab = 0),
                child: Text(
                  'See all ${r.menuItems.length} items',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            'No items in this category',
            style: AppTypography.body2.copyWith(color: AppColors.neutral400),
          ),
        ),
      );
    }
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
          border: Border(top: BorderSide(color: AppColors.border)),
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

// ── Menu Tab Row ──────────────────────────────────────────────────────────────

class _MenuTabRow extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const _MenuTabRow({
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isActive = entry.key == activeIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: entry.key < tabs.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[entry.key],
                  style: AppTypography.body2.copyWith(
                    color: isActive ? AppColors.white : AppColors.neutral,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
        border: Border.all(color: AppColors.border),
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
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

// ── Circle Button (hero overlay) ──────────────────────────────────────────────

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: AppSpacing.iconSm, color: AppColors.neutral),
        ),
      ),
    );
  }
}

// ── Share Sheet ───────────────────────────────────────────────────────────────

class _RestaurantShareSheet extends StatelessWidget {
  final RestaurantModel restaurant;

  const _RestaurantShareSheet({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Share Restaurant', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                restaurant.name,
                style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ShareOption(
                icon: Icons.link_outlined,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    _buildSnackBar(
                      context,
                      'Link copied to clipboard',
                      AppColors.success,
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.chat_outlined,
                label: 'Share via WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    _buildSnackBar(
                      context,
                      'Opening WhatsApp…',
                      AppColors.secondary,
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.person_add_outlined,
                label: 'Send to a Friend',
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) =>
                        _FriendSelectorSheet(restaurant: restaurant),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _ShareOption(
                icon: Icons.download_outlined,
                label: 'Save to Device',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    _buildSnackBar(
                      context,
                      'Restaurant saved to your device',
                      AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  SnackBar _buildSnackBar(
    BuildContext context,
    String message,
    Color color,
  ) {
    return SnackBar(
      content: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTypography.body1.copyWith(color: AppColors.white),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.white, size: 14),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}

// ── Share Option Row ──────────────────────────────────────────────────────────

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, size: 20, color: AppColors.neutral700),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.body1),
          ],
        ),
      ),
    );
  }
}

// ── Friend Selector Sheet ─────────────────────────────────────────────────────

const _kMockFriends = [
  ('Aisha Rahman', 'A'),
  ('Ben Lim', 'B'),
  ('Chloe Tan', 'C'),
  ('David Wong', 'D'),
  ('Erica Malik', 'E'),
];

class _FriendSelectorSheet extends StatefulWidget {
  final RestaurantModel restaurant;

  const _FriendSelectorSheet({required this.restaurant});

  @override
  State<_FriendSelectorSheet> createState() => _FriendSelectorSheetState();
}

class _FriendSelectorSheetState extends State<_FriendSelectorSheet> {
  final Set<String> _selected = {};

  void _send(BuildContext context) {
    if (_selected.isEmpty) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Restaurant sent to ${_selected.length} friend${_selected.length > 1 ? 's' : ''}',
                style: AppTypography.body1.copyWith(color: AppColors.white),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 14),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Send to a Friend', style: AppTypography.headline2),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.restaurant.name,
                    style:
                        AppTypography.body2.copyWith(color: AppColors.neutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            ..._kMockFriends.map((f) {
              final isSelected = _selected.contains(f.$1);
              return InkWell(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selected.remove(f.$1);
                  } else {
                    _selected.add(f.$1);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 2,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            f.$2,
                            style: AppTypography.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(f.$1, style: AppTypography.body1)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty ? () => _send(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.neutral200,
                    disabledForegroundColor: AppColors.neutral400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Select friends to send'
                        : 'Send to ${_selected.length} friend${_selected.length > 1 ? 's' : ''}',
                    style: AppTypography.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
