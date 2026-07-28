import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/banner/banner_model.dart';
import 'firestore_service.dart';

class BannerFirestore {
  const BannerFirestore();

  CollectionReference<Map<String, dynamic>> get _banners =>
      FirestoreService.col(FirestoreConstants.banners);

  Stream<List<BannerModel>> watchActiveBanners() {
    return _banners
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(BannerModel.fromFirestore).toList());
  }

  // Admin
  Stream<List<BannerModel>> watchAdminBanners() {
    return _banners
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(BannerModel.fromFirestore).toList());
  }

  Future<String> create(BannerModel banner) async {
    final docRef = _banners.doc();
    final now = DateTime.now();
    final payload = banner.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Future<void> update(BannerModel banner) async {
    await _banners.doc(banner.id).set(
      banner.copyWith(updatedAt: DateTime.now()).toFirestore(),
      SetOptions(merge: true),
    );
  }
}
