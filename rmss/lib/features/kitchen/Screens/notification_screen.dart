import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_bloc.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_event.dart';
import 'package:rmss/core/blocs/notification_bloc/app_notification_state.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/features/kitchen/widget/notification_card.dart';
import 'package:rmss/core/blocs/table_bloc/table_bloc.dart';
import 'package:rmss/core/blocs/table_bloc/table_event.dart';
import 'package:rmss/core/blocs/table_bloc/table_state.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppNotificationBloc, AppNotificationState>(
      builder: (context, state) {
        List<AppNotificationModel> notifications = [];
        if (state is AppNotificationLoaded) {
          notifications = state.notifications;
        }
        
        int unreadCount = notifications.where((n) => !n.isRead).length;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.onBack != null || Navigator.canPop(context))
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notifications",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$unreadCount unread alerts",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () {
                    context.read<AppNotificationBloc>().add(const MarkAllNotificationsAsRead());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text("Mark All Read"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  
                  Widget? actionBtn;
                  if (notification.title == "Table Needs Help" && notification.relatedId != null) {
                    actionBtn = ElevatedButton(
                      onPressed: () {
                        try {
                          final tableState = context.read<TableBloc>().state;
                          if (tableState is TablesLoaded) {
                            final table = tableState.items.firstWhere(
                              (t) => t.id == notification.relatedId,
                            );
                            if (table.needsHelp) {
                              context.read<TableBloc>().add(
                                UpdateTable(item: table.copyWith(needsHelp: false))
                              );
                            }
                          }
                        } catch (_) {
                          // Ignore if TableBloc is not found or table is missing
                        }
                        
                        // Mark as read and optionally dismiss or clear
                        context.read<AppNotificationBloc>().add(
                          MarkNotificationAsRead(notification.id)
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text("Done"),
                    );
                  }

                  return NotificationCard(
                    notification: notification,
                    actionButton: actionBtn,
                    onTap: () {
                      context.read<AppNotificationBloc>().add(MarkNotificationAsRead(notification.id));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
