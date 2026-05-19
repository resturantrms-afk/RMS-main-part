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
}
