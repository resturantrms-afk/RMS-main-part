import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/models/user_model.dart';

class AppNotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<AppNotificationModel>> _controller =
      StreamController<List<AppNotificationModel>>.broadcast();

  StreamSubscription? _notificationsSub;
  List<AppNotificationModel> _notifications = [];
  UserRoles? _currentRole;

  AppNotificationRepository();

  List<AppNotificationModel> get currentNotifications =>
      List.unmodifiable(_notifications);

  Stream<List<AppNotificationModel>> get notificationsStream =>
      _controller.stream;

  void reset() {
    _notificationsSub?.cancel();
    _notificationsSub = null;
    _notifications.clear();
    _currentRole = null;
    if (!_controller.isClosed) {
      _controller.add([]);
    }
  }

  void startListening(UserRoles role) {
    reset();
    _currentRole = role;

    final yesterday = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    _notificationsSub = _firestore
        .collection('notifications')
        .where('targetRoles', arrayContains: role.name)
        .where('isRead', isEqualTo: false)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: yesterday.toDate().toIso8601String(),
        )
        .snapshots()
        .listen((snapshot) {
          _handleNotificationsSnapshot(snapshot);
        });
  }

  void _handleNotificationsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    bool hasNew = false;

    // Convert all current documents in the snapshot to models
    _notifications = snapshot.docs
        .map((doc) => AppNotificationModel.fromJson(doc.data(), doc.id))
        .toList();

    // Sort descending by timestamp
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Check if there are newly added or modified notifications to trigger haptic/sound
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        final changedNotif = AppNotificationModel.fromJson(change.doc.data()!, change.doc.id);
        if (changedNotif.playSound) {
          hasNew = true;
          break;
        }
      }
    }

    if (hasNew) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    }

    _controller.add(List<AppNotificationModel>.from(_notifications));
  }

  Future<void> markAllRead() async {
    for (var notif in _notifications) {
      await _firestore.collection('notifications').doc(notif.id).update({
        'isRead': true,
      });
    }
    // Snapshot listener will automatically remove them from the list since we query where isRead == false
  }

  Future<void> markRead(String id) async {
    // Some older UI calls might pass relatedId instead of notification id.
    // Let's find the exact notification id first if it exists in our current list.
    final notifToUpdate = _notifications
        .where((n) => n.id == id || n.relatedId == id)
        .toList();
    for (var notif in notifToUpdate) {
      await _firestore.collection('notifications').doc(notif.id).update({
        'isRead': true,
      });
    }
  }

  Future<void> removeNotification(String id) async {
    await markRead(id);
  }

  void dispose() {
    _notificationsSub?.cancel();
    _controller.close();
  }
}
