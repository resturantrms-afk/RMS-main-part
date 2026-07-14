import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_event.dart';
import 'package:rmss/features/cashier/blocs/notification_bloc/cashier_notification_state.dart';
import 'package:rmss/features/cashier/repository/cashier_notification_repository.dart';

class CashierNotificationBloc extends Bloc<CashierNotificationEvent, CashierNotificationState> {
  final CashierNotificationRepository repository;
  StreamSubscription? _sub;

  CashierNotificationBloc({required this.repository}) : super(CashierNotificationInitial()) {
    on<StartListeningNotifications>((event, emit) {
      _sub?.cancel();
      _sub = repository.notificationsStream.listen((notification) {
        add(NotificationReceived(notification));
      });
    });

    on<NotificationReceived>((event, emit) {
      emit(CashierNotificationShow(event.notification));
      // Reset state so consecutive notifications aren't ignored
      emit(CashierNotificationInitial());
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
