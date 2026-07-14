import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/kitchen/model/notification_model.dart';
import 'package:rmss/features/kitchen/services/kitchen_notification_service.dart';
import 'package:rmss/features/kitchen/widget/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  late final KitchenNotificationService _notificationService;
  final List<NotificationModel> notifications = [];

  StreamSubscription<List<NotificationModel>>? _subscription;

  @override
  void initState() {
    super.initState();
    _notificationService = context.read<KitchenNotificationService>();
    _subscription = _notificationService.notificationsStream.listen((items) {
      if (!mounted) {
        return;
      }
      setState(() {
        notifications
          ..clear()
          ..addAll(items);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  void markAllRead() {
    setState(() {
      for (var n in notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E17),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "$unreadCount unread alerts",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () {
                    _notificationService.markAllRead();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "Mark All Read",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {

                  final notification =
                      notifications[index];

                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      // Prefer service-side state update so stream reflects change
                      _notificationService.markRead(notification.orderId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}