import 'package:flutter/material.dart';

enum NotificationType {
  order,
  inventory,
  system,
}

class NotificationModel {
  final String title;
  final String description;
  final String time;
  final NotificationType type;
  final String? orderId;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.orderId,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.order:
        return Icons.restaurant_menu;
      case NotificationType.inventory:
        return Icons.inventory_2;
      case NotificationType.system:
        return Icons.settings;
    }
  }
}