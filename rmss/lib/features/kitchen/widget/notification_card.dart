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
    return Card(
      color: notification.isRead
          ? const Color(0xFF1E1E1E)
          : const Color(0xFF2A1F10),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: Icon(
            notification.icon,
            color: Colors.orange,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            color: notification.isRead ? Colors.white70 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.description,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              notification.time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            if (!notification.isRead)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.orange,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}