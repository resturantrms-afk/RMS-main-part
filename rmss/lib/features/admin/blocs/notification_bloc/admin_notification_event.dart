import 'package:rmss/features/admin/repository/admin_notification_repository.dart';

abstract class AdminNotificationEvent {}

class StartListeningNotifications extends AdminNotificationEvent {}

class NotificationReceived extends AdminNotificationEvent {
  final AdminNotification notification;
  NotificationReceived(this.notification);
}
