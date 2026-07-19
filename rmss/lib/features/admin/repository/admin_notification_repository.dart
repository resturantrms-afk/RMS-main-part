import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/order_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdminNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool playSound;
  final double volume;

  AdminNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.playSound = true,
    this.volume = 75.0,
  });
}

class AdminNotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<AdminNotification> _controller =
      StreamController<AdminNotification>.broadcast();
  StreamSubscription? _ordersSub;

  bool _isInitialOrdersLoaded = false;

  Stream<AdminNotification> get notificationsStream {
    _startListening();
    return _controller.stream;
  }

  void _startListening() {
    if (_ordersSub != null) return;

    _ordersSub ??= _firestore.collection('orders').snapshots().listen((
      snapshot,
    ) async {
      if (!_isInitialOrdersLoaded) {
        _isInitialOrdersLoaded = true;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final playSound = prefs.getBool('adminSoundAlerts') ?? true;
      final volume = prefs.getDouble('adminAlertVolume') ?? 75.0;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.added) {
          final order = OrderModel.fromJson(change.doc.data()!, change.doc.id);
          if (order.status == OrderStatus.served) {
            _controller.add(
              AdminNotification(
                title: "Order Served",
                message:
                    "Order for Table ${order.tableNumber} has been served.",
                timestamp: DateTime.now(),
                playSound: playSound,
                volume: volume,
              ),
            );
          }
        }
      }
    });
  }

  void dispose() {
    _ordersSub?.cancel();
    _controller.close();
  }
}
