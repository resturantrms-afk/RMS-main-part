import 'package:rmss/features/admin/repository/admin_notification_repository.dart';

abstract class AdminNotificationState {}

class AdminNotificationInitial extends AdminNotificationState {}

class AdminNotificationShow extends AdminNotificationState {
  final AdminNotification notification;
  AdminNotificationShow(this.notification);
}
