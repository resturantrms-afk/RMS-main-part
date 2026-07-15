import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/order_model.dart';

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
  }

  Future<void> updateOrder(OrderModel item) async {
    await _firestore.collection('orders').doc(item.id).update(item.toJson());
  }

  Future<void> deleteOrder(OrderModel item) async {
    await _firestore.collection('orders').doc(item.id).delete();
  }

  int getActiveOrders(List<OrderModel> orders) {
    return orders.where((o) => o.status != OrderStatus.paid && o.status != OrderStatus.cancelled).length;
  }

  int getUnpaidTabs(List<OrderModel> orders) {
    return orders.where((o) => o.status == OrderStatus.served).length;
  }

  int getCompletedOrdersForDate(List<OrderModel> orders, DateTime date) {
    return orders.where((o) => o.status == OrderStatus.paid && _isSameDay(o.createdAt.toDate(), date)).length;
  }

  int getCounterOrdersForDate(List<OrderModel> orders, DateTime date) {
    return orders.where((o) => o.source == OrderSource.pos && _isSameDay(o.createdAt.toDate(), date)).length;
  }

  int getCompletedOrdersForUserAndDate(List<OrderModel> orders, String userId, DateTime date) {
    return orders.where((o) => o.status == OrderStatus.paid && o.createdBy['id'] == userId && _isSameDay(o.createdAt.toDate(), date)).length;
  }

  String getActiveOrdersPercentage(List<OrderModel> orders) {
    DateTime now = DateTime.now();
    DateTime oneHourAgo = now.subtract(const Duration(hours: 1));
    DateTime twoHoursAgo = now.subtract(const Duration(hours: 2));

    int lastHour = orders.where((o) => o.createdAt.toDate().isAfter(oneHourAgo)).length;
    int previousHour = orders.where((o) => o.createdAt.toDate().isAfter(twoHoursAgo) && o.createdAt.toDate().isBefore(oneHourAgo)).length;

    if (previousHour == 0) return lastHour > 0 ? "+100% vs last hour" : "0% vs last hour";
    double percent = ((lastHour - previousHour) / previousHour) * 100;
    return "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% vs last hour";
  }

  String getCompletedOrdersPercentage(List<OrderModel> orders, DateTime selectedDate) {
    DateTime yesterday = selectedDate.subtract(const Duration(days: 1));
    int todayCount = getCompletedOrdersForDate(orders, selectedDate);
    int yesterdayCount = getCompletedOrdersForDate(orders, yesterday);

    if (yesterdayCount == 0) return todayCount > 0 ? "+100% vs yesterday" : "0% vs yesterday";
    double percent = ((todayCount - yesterdayCount) / yesterdayCount) * 100;
    return "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% vs yesterday";
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
