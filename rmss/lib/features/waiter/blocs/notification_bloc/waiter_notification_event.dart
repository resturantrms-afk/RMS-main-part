import 'package:rmss/features/waiter/repository/waiter_notification_repository.dart';

abstract class WaiterNotificationEvent {}

class WaiterStartListeningNotifications extends WaiterNotificationEvent {}

class WaiterNotificationReceived extends WaiterNotificationEvent {
  final WaiterNotification notification;
  WaiterNotificationReceived(this.notification);
}
