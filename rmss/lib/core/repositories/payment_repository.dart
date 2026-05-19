import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PaymentModel>> getPayments() {
    return _firestore.collection('payments').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPayment(PaymentModel item) async {
    await _firestore.collection('payments').add(item.toJson());
  }

  Future<void> updatePayments(PaymentModel item) async {
    await _firestore.collection('payments').doc(item.id).update(item.toJson());
  }

  Future<void> deletePayment(PaymentModel item) async {
    await _firestore.collection('payments').doc(item.id).delete();
  }
}
