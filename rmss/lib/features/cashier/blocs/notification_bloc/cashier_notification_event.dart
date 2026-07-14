import 'package:rmss/features/cashier/repository/cashier_notification_repository.dart';

abstract class CashierNotificationEvent {}

class StartListeningNotifications extends CashierNotificationEvent {}

class NotificationReceived extends CashierNotificationEvent {
  final CashierNotification notification;
  NotificationReceived(this.notification);
}
