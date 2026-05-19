import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/menu_item_model.dart';

class MenuRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MenuItemModel>> getMenuItems() {
    return _firestore.collection('menu_items').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await _firestore.collection('menu_items').add(item.toJson());
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestore
        .collection('menu_items')
        .doc(item.id)
        .update(item.toJson());
  }

  Future<void> deleteMenuItem(MenuItemModel item) async {
    await _firestore.collection('menu_items').doc(item.id).delete();
  }
}
