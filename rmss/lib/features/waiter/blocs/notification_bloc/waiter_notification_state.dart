import 'package:rmss/features/waiter/repository/waiter_notification_repository.dart';

abstract class WaiterNotificationState {}

class WaiterNotificationInitial extends WaiterNotificationState {}

class WaiterNotificationShow extends WaiterNotificationState {
  final WaiterNotification notification;
  WaiterNotificationShow(this.notification);
}
