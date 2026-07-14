import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rmss/features/kitchen/model/notification_model.dart';

class KitchenNotificationService {
  KitchenNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _controller = StreamController<List<NotificationModel>>.broadcast() {
    _controller.onListen = () {
      if (_notifications.isNotEmpty) {
        _controller.add(List<NotificationModel>.from(_notifications));
      }
    };
  }

  final FirebaseFirestore _firestore;
  final StreamController<List<NotificationModel>> _controller;
  final List<NotificationModel> _notifications = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _hasSeenInitialSnapshot = false;

  Stream<List<NotificationModel>> get notificationsStream => _controller.stream;

  void startListening() {
    _hasSeenInitialSnapshot = false;
    _subscription?.cancel();

    _subscription = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!_hasSeenInitialSnapshot) {
        _hasSeenInitialSnapshot = true;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added &&
            change.type != DocumentChangeType.modified) {
          continue;
        }

        final data = change.doc.data();
        if (data == null) {
          continue;
        }

        final status = (data['status'] ?? '') as String;
        if (status.toLowerCase() == 'paid') {
          continue;
        }

        final orderId = change.doc.id;
        final alreadyExists = _notifications.any((item) => item.orderId == orderId);
        if (alreadyExists) {
          continue;
        }

        final tableNumber = data['tableNumber'] ?? 0;
        final createdAtRaw = data['createdAt'];
        DateTime? createdAtDt;
        if (createdAtRaw is Timestamp) {
          createdAtDt = createdAtRaw.toDate();
        } else if (createdAtRaw is DateTime) {
          createdAtDt = createdAtRaw;
        }

        final notification = NotificationModel(
          title: 'New Order Received',
          description: 'Table $tableNumber placed a new order ($status).',
          time: _formatTime(createdAtDt),
          type: NotificationType.order,
          orderId: orderId,
        );

        _notifications.insert(0, notification);
        _controller.add(List<NotificationModel>.from(_notifications));

        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.alert);
      }
    });
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    // Fallback date format: dd/MM HH:mm
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(dt.day)}/${twoDigits(dt.month)} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  }

  /// Marks all known notifications as read and emits the updated list.
  void markAllRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _controller.add(List<NotificationModel>.from(_notifications));
  }

  /// Marks a single notification (identified by [orderId]) as read.
  void markRead(String? orderId) {
    if (orderId == null) return;
    final idx = _notifications.indexWhere((n) => n.orderId == orderId);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      _controller.add(List<NotificationModel>.from(_notifications));
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
