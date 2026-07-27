import 'package:flutter/material.dart';

enum AppNotificationType { order, table, system }

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AppNotificationType type;
  final String? relatedId;
  final bool playSound;
  final double volume;
  bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.relatedId,
    this.playSound = true,
    this.volume = 75.0,
    this.isRead = false,
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    AppNotificationType? type,
    String? relatedId,
    bool? playSound,
    double? volume,
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      playSound: playSound ?? this.playSound,
      volume: volume ?? this.volume,
      isRead: isRead ?? this.isRead,
    );
  }

  IconData get icon {
    switch (type) {
      case AppNotificationType.order:
        return Icons.restaurant_menu;
      case AppNotificationType.table:
        return Icons.table_restaurant;
      case AppNotificationType.system:
        return Icons.settings;
    }
  }

  String timeAgo() {
    Duration duration = DateTime.now().difference(timestamp);
    if (duration.inDays > 0) {
      return "${duration.inDays} days ago";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} hrs ago";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} mins ago";
    } else {
      return "Just now";
    }
  }
}
