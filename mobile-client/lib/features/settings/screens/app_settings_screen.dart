import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/dialogs/logout_dialog.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Settings',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(context, ref),
              const SizedBox(height: AppSpacing.xxl),
              _buildPreferencesSection(context, ref),
              const SizedBox(height: AppSpacing.xxl),
              _buildAccountSection(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildAboutRow(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authControllerProvider).currentUser;
    final displayName = currentUser?.displayName ?? '';
    final email = currentUser?.email ?? '';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final avatarUrl = currentUser?.profile.avatar;

    return InkWell(
      onTap: () => context.push('/profile/edit'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Center(
                        child: Text(
                          initials,
                          style: AppTypography.headline3
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      errorWidget: (_, _, _) => Center(
                        child: Text(
                          initials,
                          style: AppTypography.headline3
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: AppTypography.headline3.copyWith(color: AppColors.white),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: AppTypography.headline2),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    email,
                    style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              size: AppSpacing.iconMd,
              color: AppColors.neutral600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
    final locationPermission =
        ref.watch(locationPermissionStatusProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: AppTypography.headline3.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                value: 'System default',
                isFirst: true,
                onTap: () {},
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.language,
                label: 'Language',
                value: 'English',
                onTap: () {},
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: _locationPermissionLabel(locationPermission),
                onTap: () {},
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.push('/settings/notifications'),
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy & Data',
                isLast: true,
                onTap: () => context.push('/settings/privacy'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return AppButton(
      label: 'Log Out',
      variant: AppButtonVariant.outlined,
      leadingIcon: Icons.logout,
      onPressed: () => showLogoutDialog(context),
    );
  }

  Widget _buildAboutRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: _SettingsRow(
        icon: Icons.info_outlined,
        label: 'About Mapetite',
        isFirst: true,
        isLast: true,
        onTap: () => context.push('/about'),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final label =
              info == null ? '' : 'Mapetite v${info.version} · Build ${info.buildNumber}';
          return Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.neutral400),
          );
        },
      ),
    );
  }
}

String? _locationPermissionLabel(LocationPermission? permission) {
  switch (permission) {
    case LocationPermission.always:
      return 'Always allowed';
    case LocationPermission.whileInUse:
      return 'While using app';
    case LocationPermission.denied:
      return 'Not allowed';
    case LocationPermission.deniedForever:
      return 'Denied';
    case LocationPermission.unableToDetermine:
      return 'Unknown';
    case null:
      return null;
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
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
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: AppSpacing.iconMd, color: AppColors.neutral600),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: AppSpacing.lg,
    );
  }
}
