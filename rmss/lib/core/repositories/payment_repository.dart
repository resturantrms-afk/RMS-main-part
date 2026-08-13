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

  double getTotalRevenueForDate(List<PaymentModel> payments, DateTime date) {
    double total = 0;
    for (var p in payments) {
      if (_isSameDay(p.createdAt.toDate(), date)) {
        total += p.amountPaid;
      }
    }
    return total;
  }

  double getShiftRegisterForUserAndDate(List<PaymentModel> payments, String userId, DateTime date) {
    double total = 0;
    for (var p in payments) {
      if (_isSameDay(p.createdAt.toDate(), date) && p.processedBy.containsValue(userId)) {
        total += p.amountPaid;
      }
    }
    return total;
  }

  int getCompletedOrdersProcessedByUserAndDate(List<PaymentModel> payments, String userId, DateTime date) {
    int count = 0;
    for (var p in payments) {
      if (_isSameDay(p.createdAt.toDate(), date) && p.processedBy.containsValue(userId)) {
        count++;
      }
    }
    return count;
  }

  String getRevenuePercentage(List<PaymentModel> payments, DateTime selectedDate) {
    DateTime yesterday = selectedDate.subtract(const Duration(days: 1));
    double todayRevenue = getTotalRevenueForDate(payments, selectedDate);
    double yesterdayRevenue = getTotalRevenueForDate(payments, yesterday);

    if (yesterdayRevenue == 0) return todayRevenue > 0 ? "+100% vs yesterday" : "0% vs yesterday";
    double percent = ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
    return "${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% vs yesterday";
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Map<PaymentMethod, double> getPaymentMethodDistribution(List<PaymentModel> payments, DateTime date) {
    double totalCash = 0;
    double totalZaad = 0;
    double totalEdahab = 0;

    for (var p in payments) {
      if (_isSameDay(p.createdAt.toDate(), date)) {
        if (p.paymentMethod == PaymentMethod.cash) {
          totalCash += p.amountPaid;
        } else if (p.paymentMethod == PaymentMethod.zaad) {
          totalZaad += p.amountPaid;
        } else if (p.paymentMethod == PaymentMethod.edahab) {
          totalEdahab += p.amountPaid;
        }
      }
    }

    double grandTotal = totalCash + totalZaad + totalEdahab;
    return {
      PaymentMethod.cash: grandTotal == 0 ? 0 : totalCash / grandTotal,
      PaymentMethod.zaad: grandTotal == 0 ? 0 : totalZaad / grandTotal,
      PaymentMethod.edahab: grandTotal == 0 ? 0 : totalEdahab / grandTotal,
    };
  }
}
