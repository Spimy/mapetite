import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationCategory { budget, grocery, recommendation, welcome }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String,
      body: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  /// The backend has no category/type field, so this is inferred from the
  /// notification's title. Good enough for icon/color styling; if the
  /// backend ever adds a real type field, prefer that instead.
  NotificationCategory get category {
    final lower = title.toLowerCase();
    if (lower.contains('budget')) return NotificationCategory.budget;
    if (lower.contains('recommend') || lower.contains('match')) {
      return NotificationCategory.recommendation;
    }
    if (lower.contains('grocery') || lower.contains('store')) {
      return NotificationCategory.grocery;
    }
    return NotificationCategory.welcome;
  }

  String get timestamp {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 14) return '1 week ago';

    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  }

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
