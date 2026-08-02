import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/models/user_model.dart';
import 'package:rmss/core/utils/order_utils.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getOrders() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addOrder(OrderModel item) async {
    await _firestore.collection('orders').add(item.toJson());

    // Push new order notification
    final notifId = '${item.id}_new';
    final notif = AppNotificationModel(
      id: notifId,
      title: 'New Order',
      message: 'Table ${item.tableNumber} placed a new order.',
      timestamp: DateTime.now(),
      type: AppNotificationType.order,
      relatedId: item.id,
      isRead: false,
      targetRoles: [UserRoles.kitchen.name],
    );
    await _firestore
        .collection('notifications')
        .doc(notifId)
        .set(notif.toJson(), SetOptions(merge: true));
  }

  Future<void> updateOrder(OrderModel item) async {
    await _firestore.collection('orders').doc(item.id).update(item.toJson());

    // Push update notifications based on status
    if (item.status == OrderStatus.ready) {
      final notifId = '${item.id}_ready';
      final notif = AppNotificationModel(
        id: notifId,
        title: 'Order Ready',
        message: 'Order for Table ${item.tableNumber} is ready to be served.',
        timestamp: DateTime.now(),
        type: AppNotificationType.order,
        relatedId: item.id,
        isRead: false,
        targetRoles: [UserRoles.waiter.name],
      );
      await _firestore
          .collection('notifications')
          .doc(notifId)
          .set(notif.toJson(), SetOptions(merge: true));
    } else if (item.status == OrderStatus.served) {
      final notifId = '${item.id}_served';
      final notif = AppNotificationModel(
        id: notifId,
        title: 'Order Served',
        message: 'Order for Table ${item.tableNumber} has been served.',
        timestamp: DateTime.now(),
        type: AppNotificationType.order,
        relatedId: item.id,
        isRead: false,
        targetRoles: [UserRoles.cashier.name, UserRoles.admin.name],
      );
      await _firestore
          .collection('notifications')
          .doc(notifId)
          .set(notif.toJson(), SetOptions(merge: true));
    } else if (item.status != OrderStatus.paid &&
        item.status != OrderStatus.cancelled) {
      final notifId = '${item.id}_updated';
      final notif = AppNotificationModel(
        id: notifId,
        title: 'Order Updated',
        message: 'Table ${item.tableNumber} order has been updated.',
        timestamp: DateTime.now(),
        type: AppNotificationType.order,
        relatedId: item.id,
        isRead: false, // Make it unread again if updated
        targetRoles: [UserRoles.kitchen.name],
      );
      await _firestore
          .collection('notifications')
          .doc(notifId)
          .set(notif.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> deleteOrder(OrderModel item) async {
    await _firestore.collection('orders').doc(item.id).delete();
  }

  int getActiveOrders(List<OrderModel> orders) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    return grouped
        .where(
          (o) =>
              o.status != OrderStatus.paid && o.status != OrderStatus.cancelled,
        )
        .length;
  }

  int getUnpaidTabs(List<OrderModel> orders) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    return grouped.where((o) => o.status == OrderStatus.served).length;
  }

  int getCompletedOrdersForDate(List<OrderModel> orders, DateTime date) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    return grouped
        .where(
          (o) =>
              o.status == OrderStatus.paid &&
              _isSameDay(o.createdAt.toDate(), date),
        )
        .length;
  }

  int getCounterOrdersForDate(List<OrderModel> orders, DateTime date) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    return grouped
        .where(
          (o) =>
              o.source == OrderSource.pos &&
              _isSameDay(o.createdAt.toDate(), date),
        )
        .length;
  }

  int getCompletedOrdersForUserAndDate(
    List<OrderModel> orders,
    String userId,
    DateTime date,
  ) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    return grouped
        .where(
          (o) =>
              o.status == OrderStatus.paid &&
              o.createdBy['id'] == userId &&
              _isSameDay(o.createdAt.toDate(), date),
        )
        .length;
  }

  String getActiveOrdersPercentage(List<OrderModel> orders) {
    final grouped = OrderUtils.groupActiveOrdersByTable(orders);
    DateTime now = DateTime.now();
    DateTime oneHourAgo = now.subtract(const Duration(hours: 1));
    DateTime twoHoursAgo = now.subtract(const Duration(hours: 2));

    int lastHour = grouped
        .where((o) => o.createdAt.toDate().isAfter(oneHourAgo))
        .length;
    int previousHour = grouped
        .where(
          (o) =>
              o.createdAt.toDate().isAfter(twoHoursAgo) &&
              o.createdAt.toDate().isBefore(oneHourAgo),
        )
        .length;

    if (previousHour == 0)
      return lastHour > 0 ? "+100% vs last hour" : "0% vs last hour";
    double percent = ((lastHour - previousHour) / previousHour) * 100;
    return "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% vs last hour";
  }

  String getCompletedOrdersPercentage(
    List<OrderModel> orders,
    DateTime selectedDate,
  ) {
    DateTime yesterday = selectedDate.subtract(const Duration(days: 1));
    int todayCount = getCompletedOrdersForDate(orders, selectedDate);
    int yesterdayCount = getCompletedOrdersForDate(orders, yesterday);

    if (yesterdayCount == 0)
      return todayCount > 0 ? "+100% vs yesterday" : "0% vs yesterday";
    double percent = ((todayCount - yesterdayCount) / yesterdayCount) * 100;
    return "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% vs yesterday";
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
