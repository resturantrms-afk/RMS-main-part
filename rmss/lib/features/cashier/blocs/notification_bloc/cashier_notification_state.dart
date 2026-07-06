import 'package:rmss/features/cashier/repository/cashier_notification_repository.dart';

abstract class CashierNotificationState {}

class CashierNotificationInitial extends CashierNotificationState {}

class CashierNotificationShow extends CashierNotificationState {
  final CashierNotification notification;
  CashierNotificationShow(this.notification);
}
