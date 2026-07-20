import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/roles/waiter_model.dart';
import 'package:rmss/core/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Waiter Actions
  Future<void> logWaiterAction(String waiterId, WaiterAction action) async {
    try {
      final docRef = _firestore.collection('users').doc(waiterId);
      
      await docRef.update({
        'actions': FieldValue.arrayUnion([action.toJson()]),
      });
    } catch (e) {
      // In case the field doesn't exist or other error, we can use set with merge
      try {
        final docRef = _firestore.collection('users').doc(waiterId);
        await docRef.set({
          'actions': FieldValue.arrayUnion([action.toJson()]),
        }, SetOptions(merge: true));
      } catch (e) {
        // print("Error logging waiter action: $e");
      }
    }
  }

  // Cashier Stats
  Future<void> incrementCashierStats(String cashierId, double revenue) async {
    try {
      final docRef = _firestore.collection('users').doc(cashierId);
      await docRef.set({
        'totalOrdersProcessed': FieldValue.increment(1),
        'totalRevenueCollected': FieldValue.increment(revenue),
      }, SetOptions(merge: true));
    } catch (e) {
      // print("Error incrementing cashier stats: $e");
    }
  }

  // Kitchen Stats
  Future<void> incrementKitchenStats(String kitchenId) async {
    try {
      final docRef = _firestore.collection('users').doc(kitchenId);
      await docRef.set({
        'dishesPrepared': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      // print("Error incrementing kitchen stats: $e");
    }
  }

  // Admin User Management
  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'role': newRole,
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'address': user.address,
      'role': user.role.name,
      'status': user.status.name,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  /// Creates a new user document in Firestore (auth account creation must be
  /// handled separately via Firebase Auth – this only writes the profile doc).
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('users').add(userData);
  }
}
