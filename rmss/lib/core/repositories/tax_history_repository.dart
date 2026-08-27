import 'package:cloud_firestore/cloud_firestore.dart';

class TaxHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves the currently active global tax.
  Future<double> getGlobalTax() async {
    final snapshot = await _firestore.collection('app_settings').doc('tax_settings').get();
    if (snapshot.exists && snapshot.data() != null) {
      return (snapshot.data()!['taxPercent'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  /// Sets a new global tax rate.
  Future<void> updateGlobalTax(double newTaxPercent) async {
    await _firestore.collection('app_settings').doc('tax_settings').set(
      {'taxPercent': newTaxPercent},
      SetOptions(merge: true),
    );
  }
}
