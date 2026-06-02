import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_router.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.80,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSpacing.radiusXl),
          bottomRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.profileEdit);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'A',
                              style: AppTypography.headline2.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aisha',
                                style: AppTypography.headline2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Account & Preferences',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.neutral400,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'RM 47.50 Saved This Month',
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: AppColors.neutral200, height: 1),

            // ── Menu items ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Icons.restaurant_outlined,
                      label: 'Restaurants',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.explore);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Grocery Stores',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.explore);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.menu_book_outlined,
                      label: 'Recipes',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.recipes);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.checklist_outlined,
                      label: 'My List',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.myList);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.map_outlined,
                      label: 'Route Map',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.map);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Budget Analytics',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.budget);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: AppColors.neutral200, height: 1),

            // ── Settings ────────────────────────────────────────────────────
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.settings);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.neutral),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.body1.copyWith(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
