import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/models/order_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WaiterNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool playSound;
  final double volume;

  WaiterNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.playSound = true,
    this.volume = 75.0,
  });
}

class WaiterNotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<WaiterNotification> _controller = StreamController<WaiterNotification>.broadcast();
  StreamSubscription? _tablesSub;
  StreamSubscription? _ordersSub;
  
  bool _isInitialTablesLoaded = false;
  bool _isInitialOrdersLoaded = false;

  Stream<WaiterNotification> get notificationsStream {
    _startListening();
    return _controller.stream;
  }

  void _startListening() {
    if (_tablesSub != null && _ordersSub != null) return;

    _tablesSub ??= _firestore.collection('tables').snapshots().listen((snapshot) async {
      if (!_isInitialTablesLoaded) {
        _isInitialTablesLoaded = true;
        return; 
      }

      final prefs = await SharedPreferences.getInstance();
      final cleaningAlerts = prefs.getBool('cleaningAlerts') ?? true;

      if (!cleaningAlerts) return; // Ignore if disabled

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final table = TableModel.fromJson(change.doc.data()!, change.doc.id);
          if (table.status == TableStatus.needsCleaning) {
            _controller.add(WaiterNotification(
              title: "Table Needs Cleaning",
              message: "Table ${table.tableNumber} just finished and needs cleaning.",
              timestamp: DateTime.now(),
              playSound: false, // Cleaning usually doesn't need loud sound
            ));
          }
        }
      }
    });

    _ordersSub ??= _firestore.collection('orders').snapshots().listen((snapshot) async {
      if (!_isInitialOrdersLoaded) {
        _isInitialOrdersLoaded = true;
        return; 
      }

      final prefs = await SharedPreferences.getInstance();
      final playSound = prefs.getBool('soundAlerts') ?? true;
      final volume = prefs.getDouble('alertVolume') ?? 75.0;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final order = OrderModel.fromJson(change.doc.data()!, change.doc.id);
          if (order.status == OrderStatus.ready) {
            _controller.add(WaiterNotification(
              title: "Order Ready",
              message: "Order for Table ${order.tableNumber} is ready to be served.",
              timestamp: DateTime.now(),
              playSound: playSound,
              volume: volume,
            ));
          }
        }
      }
    });
  }

  void dispose() {
    _tablesSub?.cancel();
    _ordersSub?.cancel();
    _controller.close();
  }
}
