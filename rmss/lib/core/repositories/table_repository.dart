import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/table_model.dart';
import 'package:rmss/core/models/app_notification_model.dart';
import 'package:rmss/core/models/user_model.dart';

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
    
    if (item.status == TableStatus.needsCleaning) {
      final notifId = '${item.id}_clean';
      final notif = AppNotificationModel(
        id: notifId,
        title: 'Table Needs Cleaning',
        message: 'Table ${item.tableNumber} just finished and needs cleaning.',
        timestamp: DateTime.now(),
        type: AppNotificationType.table,
        relatedId: item.id,
        isRead: false,
        targetRoles: [UserRoles.waiter.name],
        playSound: false,
      );
      await _firestore.collection('notifications').doc(notifId).set(notif.toJson(), SetOptions(merge: true));
    }
    
    if (item.needsHelp) {
      final notifId = '${item.id}_help';
      final notif = AppNotificationModel(
        id: notifId,
        title: 'Table Needs Help',
        message: 'Customer at Table ${item.tableNumber} needs your help.',
        timestamp: DateTime.now(),
        type: AppNotificationType.table,
        relatedId: item.id,
        isRead: false,
        targetRoles: [UserRoles.waiter.name],
        playSound: true,
      );
      await _firestore.collection('notifications').doc(notifId).set(notif.toJson(), SetOptions(merge: true));
    }
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
