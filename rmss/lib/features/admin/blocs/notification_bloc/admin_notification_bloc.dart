import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_event.dart';
import 'package:rmss/features/admin/blocs/notification_bloc/admin_notification_state.dart';
import 'package:rmss/features/admin/repository/admin_notification_repository.dart';

class AdminNotificationBloc extends Bloc<AdminNotificationEvent, AdminNotificationState> {
  final AdminNotificationRepository repository;
  StreamSubscription? _sub;

  AdminNotificationBloc({required this.repository}) : super(AdminNotificationInitial()) {
    on<StartListeningNotifications>((event, emit) {
      _sub?.cancel();
      _sub = repository.notificationsStream.listen((notification) {
        add(NotificationReceived(notification));
      });
    });

    on<NotificationReceived>((event, emit) {
      emit(AdminNotificationShow(event.notification));
      // Reset state so consecutive notifications aren't ignored
      emit(AdminNotificationInitial());
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
