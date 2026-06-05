import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _budgetAlerts = true;
  bool _nearbyGrocery = true;
  bool _aiRecommendations = true;
  bool _promotions = false;
  bool _quietHours = false;

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
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'Notifications',
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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  label: 'All Notifications',
                  value: _allNotifications,
                  onChanged: (v) => setState(() {
                    _allNotifications = v;
                    if (!v) {
                      _budgetAlerts = false;
                      _nearbyGrocery = false;
                      _aiRecommendations = false;
                      _promotions = false;
                      _quietHours = false;
                    }
                  }),
                  isFirst: true,
                ),
                _buildDivider(),
                _buildToggleRow(
                  label: 'Budget Alerts',
                  value: _allNotifications && _budgetAlerts,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _budgetAlerts = v)
                      : null,
                ),
                _buildDivider(),
                _buildToggleRow(
                  label: 'Nearby Grocery',
                  value: _allNotifications && _nearbyGrocery,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _nearbyGrocery = v)
                      : null,
                ),
                _buildDivider(),
                _buildToggleRow(
                  label: 'AI Recommendations',
                  value: _allNotifications && _aiRecommendations,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _aiRecommendations = v)
                      : null,
                ),
                _buildDivider(),
                _buildToggleRow(
                  label: 'Promotions',
                  value: _allNotifications && _promotions,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _promotions = v)
                      : null,
                ),
                _buildDivider(),
                _buildToggleRow(
                  label: 'Quiet Hours',
                  value: _allNotifications && _quietHours,
                  onChanged: _allNotifications
                      ? (v) => setState(() => _quietHours = v)
                      : null,
                  subtitle: (_allNotifications && _quietHours)
                      ? 'Mute from 10:00 PM to 7:00 AM'
                      : null,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(AppSpacing.radiusLg) : Radius.zero,
          bottom: isLast ? const Radius.circular(AppSpacing.radiusLg) : Radius.zero,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        title: Text(
          label,
          style: AppTypography.body1.copyWith(
            color: onChanged == null ? AppColors.neutral400 : AppColors.neutral,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.body2.copyWith(color: AppColors.neutral600),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.border, indent: AppSpacing.lg);
}
