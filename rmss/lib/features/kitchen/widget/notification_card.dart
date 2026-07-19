import 'package:flutter/material.dart';
import 'package:rmss/features/kitchen/model/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
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
        subtitle: Text(
          notification.description,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              notification.time,
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