import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationCategory { budget, grocery, recommendation, welcome }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final NotificationCategory category;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.isRead = false,
  });

  Color get iconBg => switch (category) {
        NotificationCategory.budget => AppColors.warningLight,
        NotificationCategory.grocery => AppColors.secondaryLight,
        NotificationCategory.recommendation => AppColors.primaryLight,
        NotificationCategory.welcome => AppColors.neutral100,
      };

  Color get iconColor => switch (category) {
        NotificationCategory.budget => AppColors.warning,
        NotificationCategory.grocery => AppColors.secondary,
        NotificationCategory.recommendation => AppColors.primary,
        NotificationCategory.welcome => AppColors.neutral600,
      };

  IconData get icon => switch (category) {
        NotificationCategory.budget => Icons.warning_rounded,
        NotificationCategory.grocery => Icons.storefront,
        NotificationCategory.recommendation => Icons.restaurant,
        NotificationCategory.welcome => Icons.celebration,
      };
}

abstract class NotificationMocks {
  static List<AppNotification> get items => [
        AppNotification(
          id: 'n1',
          title: 'Budget Alert',
          body: "You've reached 90% of your RM500 dining budget.",
          timestamp: 'Just now',
          category: NotificationCategory.budget,
          isRead: false,
        ),
        AppNotification(
          id: 'n2',
          title: 'Near Jaya Grocer',
          body: "You're near Jaya Grocer. 3 items on your list.",
          timestamp: '2 hrs ago',
          category: NotificationCategory.grocery,
          isRead: false,
        ),
        AppNotification(
          id: 'n3',
          title: 'New recommendation',
          body: 'We found a vegan-friendly spot: Green Bowl Cafe.',
          timestamp: 'Yesterday',
          category: NotificationCategory.recommendation,
          isRead: true,
        ),
        AppNotification(
          id: 'n4',
          title: 'Welcome to Mapetite',
          body: 'Thanks for joining! Set up your preferences.',
          timestamp: 'Oct 12',
          category: NotificationCategory.welcome,
          isRead: true,
        ),
      ];
}
