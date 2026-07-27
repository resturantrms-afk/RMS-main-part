import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/app_notification_model.dart';

abstract class AppNotificationState extends Equatable {
  const AppNotificationState();
  
  @override
  List<Object?> get props => [];
}

class AppNotificationInitial extends AppNotificationState {}

class AppNotificationLoading extends AppNotificationState {}

class AppNotificationLoaded extends AppNotificationState {
  final List<AppNotificationModel> notifications;
  
  const AppNotificationLoaded(this.notifications);
  
  @override
  List<Object?> get props => [notifications];
}

class AppNotificationError extends AppNotificationState {
  final String message;
  
  const AppNotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}
