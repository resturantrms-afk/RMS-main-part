import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/menu_profile_model.dart';
import 'package:rmss/core/models/menu_item_model.dart';

class MenuProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MenuProfileModel>> getMenuProfiles() {
    return _firestore.collection('menu_profiles').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuProfileModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addMenuProfile(MenuProfileModel profile) async {
    await _firestore.collection('menu_profiles').add(profile.toJson());
  }

  Future<void> updateMenuProfile(MenuProfileModel profile) async {
    await _firestore
        .collection('menu_profiles')
        .doc(profile.id)
        .update(profile.toJson());
  }

  Future<void> deleteMenuProfile(MenuProfileModel profile) async {
    await _firestore.collection('menu_profiles').doc(profile.id).delete();
  }

  // This method syncs the active profiles to the menu items using a batch write
  Future<void> syncActiveProfilesToMenuItems(
      List<MenuProfileModel> allProfiles, List<MenuItemModel> allItems) async {
    // 1. Find all active profiles
    final activeProfiles = allProfiles.where((p) => p.isActive).toList();
    
    // If no profiles are active, we do not force everything to be unavailable.
    // This allows the system to default to "show everything" manually managed,
    // exactly as the user requested.
    if (activeProfiles.isEmpty) {
      return; 
    }

    // 2. Get a combined set of all item IDs that should be available
    final Set<String> activeItemIds = {};
    for (var profile in activeProfiles) {
      activeItemIds.addAll(profile.menuItemIds);
    }

    // 3. Prepare a Firestore batch to update items efficiently
    final WriteBatch batch = _firestore.batch();
    bool hasUpdates = false;

    for (var item in allItems) {
      final shouldBeAvailable = activeItemIds.contains(item.id);
      final currentStatus = item.status;
      
      final newStatus = shouldBeAvailable 
          ? MenuItemStatus.available 
          : MenuItemStatus.unavailable;

      if (currentStatus != newStatus) {
        hasUpdates = true;
        final docRef = _firestore.collection('menu_items').doc(item.id);
        batch.update(docRef, {'status': newStatus.name});
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }
}
