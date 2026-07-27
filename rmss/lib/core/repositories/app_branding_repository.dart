import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/app_branding_model.dart';

class AppBrandingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppBrandingModel> getBrandingStream() {
    return _firestore.collection('app_settings').doc('branding').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppBrandingModel.fromJson(snapshot.data()!);
      }
      return const AppBrandingModel(appName: 'Crown Restaurant', appLogoUrl: '');
    });
  }

  Future<void> updateBranding(AppBrandingModel branding) async {
    await _firestore.collection('app_settings').doc('branding').set(branding.toJson(), SetOptions(merge: true));
  }
}
