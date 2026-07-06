import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_event.dart';
import 'package:rmss/features/waiter/blocs/notification_bloc/waiter_notification_state.dart';
import 'package:rmss/features/waiter/repository/waiter_notification_repository.dart';

class WaiterNotificationBloc extends Bloc<WaiterNotificationEvent, WaiterNotificationState> {
  final WaiterNotificationRepository repository;
  StreamSubscription? _sub;

  WaiterNotificationBloc({required this.repository}) : super(WaiterNotificationInitial()) {
    on<WaiterStartListeningNotifications>((event, emit) {
      _sub?.cancel();
      _sub = repository.notificationsStream.listen((notification) {
        add(WaiterNotificationReceived(notification));
      });
    });

    on<WaiterNotificationReceived>((event, emit) {
      emit(WaiterNotificationShow(event.notification));
      // Reset state so consecutive notifications aren't ignored
      emit(WaiterNotificationInitial());
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
