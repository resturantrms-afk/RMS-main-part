import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppNotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<AppNotificationModel>> _controller =
      StreamController<List<AppNotificationModel>>.broadcast();
      
  StreamSubscription? _ordersSub;
  StreamSubscription? _tablesSub;

  final List<AppNotificationModel> _notifications = [];
  final Map<String, int> _cachedOrderItemsCount = {};
  UserRoles? _currentRole;
  
  bool _isInitialOrdersLoaded = false;
  bool _isInitialTablesLoaded = false;
  
  AppNotificationRepository();

  List<AppNotificationModel> get currentNotifications => List.unmodifiable(_notifications);

  Stream<List<AppNotificationModel>> get notificationsStream => _controller.stream;

  /// Clears all in-memory state and cancels Firestore subscriptions.
  /// Must be called on logout and before starting a new session.
  void reset() {
    _ordersSub?.cancel();
    _tablesSub?.cancel();
    _ordersSub = null;
    _tablesSub = null;
    _notifications.clear();
    _cachedOrderItemsCount.clear();
    _currentRole = null;
    _isInitialOrdersLoaded = false;
    _isInitialTablesLoaded = false;
    // Broadcast empty list so any active UI listeners update immediately
    if (!_controller.isClosed) {
      _controller.add([]);
    }
  }

  void startListening(UserRoles role) {
    // Always reset before starting — ensures clean state on every login
    reset();
    _currentRole = role;

    _clearIfNewDay(); // wipe notifications if it's a new calendar day

    final yesterday = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)));
    _ordersSub = _firestore
        .collection('orders')
        .where('updatedAt', isGreaterThanOrEqualTo: yesterday)
        .snapshots()
        .listen((snapshot) {
      _handleOrdersSnapshot(snapshot, role);
    });

    if (role == UserRoles.waiter) {
      _tablesSub = _firestore.collection('tables').snapshots().listen((snapshot) {
        _handleTablesSnapshot(snapshot, role);
      });
    }
  }
  
  Future<void> _handleOrdersSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot, UserRoles role) async {

    final prefs = await SharedPreferences.getInstance();
    
    for (var change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added && change.type != DocumentChangeType.modified) {
        continue;
      }
      
      final order = OrderModel.fromJson(change.doc.data()!, change.doc.id);
      AppNotificationModel? newNotification;
      
      if (role == UserRoles.waiter) {
        final volume = prefs.getDouble('alertVolume') ?? 75.0;
        
        if (order.status == OrderStatus.ready) {
          final alreadyNotified = _notifications.any(
              (n) => n.relatedId == order.id && n.title == "Order Ready"
          );
          if (!alreadyNotified) {
            newNotification = AppNotificationModel(
              id: const Uuid().v4(),
              title: "Order Ready",
              message: "Order is ready to be served.",
              timestamp: DateTime.now(),
              type: AppNotificationType.order,
              relatedId: order.id,
              playSound: volume > 0,
              volume: volume,
            );
          }
        }
      } else if (role == UserRoles.kitchen) {
        if (order.status != OrderStatus.paid && order.status != OrderStatus.served && order.status != OrderStatus.cancelled) {
          final isNew = change.type == DocumentChangeType.added;
          final currentCount = order.items.length;
          final previousCount = _cachedOrderItemsCount[order.id];
          
          bool shouldNotify = isNew || (previousCount != null && previousCount != currentCount);
          _cachedOrderItemsCount[order.id] = currentCount;

          if (shouldNotify) {
            final title = isNew ? "New Order" : "Order Updated";
            final message = isNew 
                ? "Table ${order.tableNumber} placed a new order."
                : "Table ${order.tableNumber} order has been updated.";
                
            if (!_notifications.any((n) => n.relatedId == order.id && n.title == title)) {
              newNotification = AppNotificationModel(
                id: const Uuid().v4(),
                title: title,
                message: message,
                timestamp: DateTime.now(),
                type: AppNotificationType.order,
                relatedId: order.id,
              );
              
              HapticFeedback.mediumImpact();
              SystemSound.play(SystemSoundType.alert);
            }
          }
        }
      } else if (role == UserRoles.cashier) {
        final volume = prefs.getDouble('cashierAlertVolume') ?? 75.0;
        
        if (order.status == OrderStatus.served) {
          final alreadyNotified = _notifications.any(
              (n) => n.relatedId == order.id && n.title == "Order Served"
          );
          if (!alreadyNotified) {
            newNotification = AppNotificationModel(
              id: const Uuid().v4(),
              title: "Order Served",
              message: "Order has been served.",
              timestamp: DateTime.now(),
              type: AppNotificationType.order,
              relatedId: order.id,
              playSound: volume > 0,
              volume: volume,
            );
          }
        }
      } else if (role == UserRoles.admin) {
        final volume = prefs.getDouble('adminAlertVolume') ?? 75.0;
        
        if (order.status == OrderStatus.served) {
          final alreadyNotified = _notifications.any(
              (n) => n.relatedId == order.id && n.title == "Order Served"
          );
          if (!alreadyNotified) {
            newNotification = AppNotificationModel(
              id: const Uuid().v4(),
              title: "Order Served",
              message: "Order has been served.",
              timestamp: DateTime.now(),
              type: AppNotificationType.order,
              relatedId: order.id,
              playSound: volume > 0,
              volume: volume,
            );
          }
        }
      }
      
      if (newNotification != null) {
        _notifications.insert(0, newNotification);
        _controller.add(List<AppNotificationModel>.from(_notifications));
      }
    }
  }

  Future<void> _handleTablesSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot, UserRoles role) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
        final table = TableModel.fromJson(change.doc.data()!, change.doc.id);
        
        AppNotificationModel? newNotification;
        
        if (table.status == TableStatus.needsCleaning) {
          final alreadyNotified = _notifications.any(
              (n) => n.relatedId == table.id && n.title == "Table Needs Cleaning"
          );
          if (!alreadyNotified) {
            newNotification = AppNotificationModel(
              id: const Uuid().v4(),
              title: "Table Needs Cleaning",
              message: "Table ${table.tableNumber} just finished and needs cleaning.",
              timestamp: DateTime.now(),
              type: AppNotificationType.table,
              relatedId: table.id,
              playSound: false,
            );
          }
        }
        
        if (table.needsHelp) {
          final alreadyNotified = _notifications.any(
              (n) => n.relatedId == table.id && n.title == "Table Needs Help"
          );
          if (!alreadyNotified) {
            newNotification = AppNotificationModel(
              id: const Uuid().v4(),
              title: "Table Needs Help",
              message: "Customer at Table ${table.tableNumber} needs your help.",
              timestamp: DateTime.now(),
              type: AppNotificationType.table,
              relatedId: table.id,
              playSound: true,
            );
          }
        }
        
        if (newNotification != null) {
          _notifications.insert(0, newNotification);
          _controller.add(List<AppNotificationModel>.from(_notifications));
        }
      }
    }
  }
  
  void markAllRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _controller.add(List<AppNotificationModel>.from(_notifications));
  }

  void markRead(String id) {
    bool wasUpdated = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].id == id || _notifications[i].relatedId == id) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        wasUpdated = true;
      }
    }
    if (wasUpdated) {
      _controller.add(List<AppNotificationModel>.from(_notifications));
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _controller.add(List<AppNotificationModel>.from(_notifications));
  }

  void dispose() {
    _ordersSub?.cancel();
    _tablesSub?.cancel();
    _controller.close();
  }

  /// Clears notifications if the app is opened on a new calendar day.
  Future<void> _clearIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastStr = prefs.getString('_notif_last_date') ?? '';
    if (lastStr != todayStr) {
      _notifications.clear();
      await prefs.setString('_notif_last_date', todayStr);
    }
  }
}
