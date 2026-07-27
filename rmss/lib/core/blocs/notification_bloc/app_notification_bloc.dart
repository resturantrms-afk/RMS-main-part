import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/repositories/app_notification_repository.dart';
import 'app_notification_event.dart';
import 'app_notification_state.dart';

class AppNotificationBloc extends Bloc<AppNotificationEvent, AppNotificationState> {
  final AppNotificationRepository _repository;
  StreamSubscription<List<AppNotificationModel>>? _subscription;

  AppNotificationBloc({required AppNotificationRepository repository})
      : _repository = repository,
        super(AppNotificationInitial()) {
    on<StartListeningToNotifications>(_onStartListening);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<RemoveNotification>(_onRemoveNotification);
    on<ResetNotifications>(_onReset);
  }

  void _onStartListening(
    StartListeningToNotifications event,
    Emitter<AppNotificationState> emit,
  ) {
    emit(AppNotificationLoading());
    _subscription?.cancel();
    
    _repository.startListening(event.role);
    
    _subscription = _repository.notificationsStream.listen(
      (notifications) {
        add(NotificationsUpdated(notifications));
      },
      onError: (error) {
        add(NotificationsUpdated(const []));
      },
    );
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<AppNotificationState> emit,
  ) {
    emit(AppNotificationLoaded(event.notifications));
  }

  void _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<AppNotificationState> emit,
  ) {
    _repository.markRead(event.id);
  }

  void _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<AppNotificationState> emit,
  ) {
    _repository.markAllRead();
  }

  void _onRemoveNotification(
    RemoveNotification event,
    Emitter<AppNotificationState> emit,
  ) {
    _repository.removeNotification(event.id);
  }

  void _onReset(
    ResetNotifications event,
    Emitter<AppNotificationState> emit,
  ) {
    _subscription?.cancel();
    _subscription = null;
    _repository.reset();
    emit(AppNotificationInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
