import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/toast_helpers.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationCentreScreen extends ConsumerStatefulWidget {
  const NotificationCentreScreen({super.key});

  @override
  ConsumerState<NotificationCentreScreen> createState() =>
      _NotificationCentreScreenState();
}

class _NotificationCentreScreenState
    extends ConsumerState<NotificationCentreScreen> {
  @override
  void initState() {
    super.initState();
    // Refetch whenever the notification centre is opened — the provider is
    // otherwise created once (on first home-feed build) and never
    // refreshed, so notifications created after that would never appear
    // without this.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.invalidate(notificationProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, notificationsAsync),
      body: SafeArea(
        top: false,
        child: notificationsAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, _) =>
                const ShimmerLoader(width: double.infinity, height: 72),
          ),
          error: (_, _) => AppEmptyState(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            description: 'Unable to load notifications. Please try again.',
            ctaLabel: 'Retry',
            onCta: () => ref.invalidate(notificationProvider),
          ),
          data: (notifications) => notifications.isEmpty
              ? const AppEmptyState(
                  icon: Icons.notifications_none,
                  title: 'All caught up',
                  description: 'No new notifications.',
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.refresh(notificationProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationRow(
                        notification: n,
                        onDismiss: () => _dismiss(context, n.id),
                        onTap: () => _markRead(context, n.id),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _markRead(BuildContext context, String id) async {
    try {
      await ref.read(notificationProvider.notifier).markRead(id);
    } catch (_) {
      if (context.mounted) {
        showErrorSnackbar(context, 'Could not update notification. Please try again.');
      }
    }
  }

  Future<void> _dismiss(BuildContext context, String id) async {
    try {
      await ref.read(notificationProvider.notifier).dismiss(id);
    } catch (_) {
      if (context.mounted) {
        showErrorSnackbar(context, 'Could not dismiss notification. Please try again.');
      }
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<List<AppNotification>> notificationsAsync,
  ) {
    final hasUnread = notificationsAsync.value?.any((n) => !n.isRead) ?? false;

    return AppBar(
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
        'Notifications',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      actions: [
        if (hasUnread)
          TextButton(
            onPressed: () async {
              try {
                await ref.read(notificationProvider.notifier).markAllRead();
              } catch (_) {
                if (context.mounted) {
                  showErrorSnackbar(context, 'Could not mark all as read. Please try again.');
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: Text(
              'Mark all read',
              style: AppTypography.body2.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: AppColors.white, size: AppSpacing.iconMd),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Dismiss',
              style: AppTypography.label.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          color: notification.isRead ? AppColors.white : AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(notification: notification),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _NotificationBody(notification: notification)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final AppNotification notification;
  const _IconBadge({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: notification.iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.icon,
            size: AppSpacing.iconSm,
            color: notification.iconColor,
          ),
        ),
        if (!notification.isRead)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: notification.isRead ? AppColors.white : AppColors.primaryLight,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationBody extends StatelessWidget {
  final AppNotification notification;
  const _NotificationBody({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: AppTypography.body1.copyWith(
                  fontWeight: notification.isRead
                      ? FontWeight.w500
                      : FontWeight.w600,
                  color: AppColors.neutral,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                notification.body,
                style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          notification.timestamp,
          style: AppTypography.caption.copyWith(color: AppColors.neutral400),
        ),
      ],
    );
  }
}
