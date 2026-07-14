import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/table_model.dart';

class TableRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TableModel>> getTables() {
    return _firestore.collection('tables').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TableModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addTable(TableModel item) async {
    await _firestore.collection('tables').add(item.toJson());
  }

  Future<void> updateTable(TableModel item) async {
    await _firestore.collection('tables').doc(item.id).update(item.toJson());
  }

  Future<void> deleteTable(TableModel item) async {
    await _firestore.collection('tables').doc(item.id).delete();
  }

  Future<TableModel?> getTableByNumber(int number) async {
    final snapshot = await _firestore
        .collection('tables')
        .where('tableNumber', isEqualTo: number)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return TableModel.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } else {
      return null;
    }
  }
}
