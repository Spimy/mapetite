import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_router.dart';

class AppDrawer extends StatelessWidget {
  final String displayName;
  final double savedThisMonth;

  const AppDrawer({
    super.key,
    required this.displayName,
    required this.savedThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(color: AppColors.border, height: 1),
            Expanded(child: _buildNavItems(context)),
            const Divider(color: AppColors.border, height: 1),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.push(AppRoutes.profileEdit);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Center(
                child: Image.asset(
                  'assets/logos/logo_wording.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: AppSpacing.avatarXl,
                  height: AppSpacing.avatarXl,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTypography.headline2
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.headline3
                            .copyWith(color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Account & Preferences',
                        style: AppTypography.body2
                            .copyWith(color: AppColors.neutral600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.neutral400),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SavingsPill(amount: savedThisMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItems(BuildContext context) {
    final items = [
      const _NavItem(Icons.restaurant_outlined, 'Restaurants', AppRoutes.restaurants),
      const _NavItem(Icons.local_grocery_store_outlined, 'Grocery Stores', AppRoutes.groceries),
      const _NavItem(Icons.menu_book_outlined, 'Recipes', AppRoutes.cookIn),
      const _NavItem(Icons.checklist_outlined, 'My List', AppRoutes.list),
      const _NavItem(Icons.map_outlined, 'Route Map', AppRoutes.listRoute),
      const _NavItem(Icons.bar_chart, 'Budget Analytics', AppRoutes.budgetAnalytics),
    ];
    return SingleChildScrollView(
      child: Column(
        children: items
            .map((item) => _DrawerNavItem(
                  icon: item.icon,
                  label: item.label,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(item.route);
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return _DrawerNavItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      onTap: () {
        Navigator.of(context).pop();
        context.push(AppRoutes.settings);
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

class _SavingsPill extends StatelessWidget {
  final double amount;
  const _SavingsPill({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.savings_outlined,
              size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              'RM ${amount.toStringAsFixed(2)} Saved This Month',
              style: AppTypography.label
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.iconSm, color: AppColors.neutral600),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label,
                  style: AppTypography.body1.copyWith(color: AppColors.neutral),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
