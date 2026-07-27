import 'package:flutter/material.dart';
import 'package:rmss/core/models/app_notification_model.dart';

class NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  final Widget? actionButton;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      color: notification.isRead
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            notification.icon,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            color: notification.isRead ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notification.message,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 8),
              actionButton!,
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              notification.timeAgo(),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: colorScheme.primary,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}