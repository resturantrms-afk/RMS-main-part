import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/models/user_model.dart';

abstract class AppNotificationEvent extends Equatable {
  const AppNotificationEvent();

  @override
  List<Object?> get props => [];
}

class StartListeningToNotifications extends AppNotificationEvent {
  final UserRoles role;

  const StartListeningToNotifications({required this.role});

  @override
  List<Object?> get props => [role];
}

class NotificationsUpdated extends AppNotificationEvent {
  final List<AppNotificationModel> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class MarkNotificationAsRead extends AppNotificationEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsRead extends AppNotificationEvent {
  const MarkAllNotificationsAsRead();
}

class RemoveNotification extends AppNotificationEvent {
  final String id;
  
  const RemoveNotification(this.id);
  
  @override
  List<Object?> get props => [id];
}

class ResetNotifications extends AppNotificationEvent {
  const ResetNotifications();
}
