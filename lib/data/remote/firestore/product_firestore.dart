import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/product/product_model.dart';
import 'firestore_service.dart';

class ProductFirestore {
  const ProductFirestore();

  CollectionReference<Map<String, dynamic>> get _products =>
      FirestoreService.col(FirestoreConstants.products);

  Future<ProductModel?> getById(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) return null;
    final model = ProductModel.fromFirestore(doc);
    if (model.isDeleted) return null;
    return model;
  }

  Stream<ProductModel?> watchById(String productId) {
    return _products.doc(productId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final model = ProductModel.fromFirestore(doc);
      if (model.isDeleted) return null;
      return model;
    });
  }

  Future<List<ProductModel>> getFeatured({int limit = 10}) async {
    final snap = await _products
        .where('isDeleted', isEqualTo: false)
        .where('isAvailable', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<List<ProductModel>> getNewArrivals({int limit = 10}) async {
    final snap = await _products
        .where('isDeleted', isEqualTo: false)
        .where('isAvailable', isEqualTo: true)
        .where('isNewArrival', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<List<ProductModel>> getByCategory({
    required String categoryId,
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    var q = _products
        .where('isDeleted', isEqualTo: false)
        .where('isAvailable', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) q = q.startAfterDocument(startAfter);

    final snap = await q.get();
    return snap.docs.map(ProductModel.fromFirestore).toList();
  }

  // Prefix search (requires `nameLower` field)
  Future<List<ProductModel>> searchByNamePrefix({
    required String query,
    int limit = 20,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final snap = await _products
        .where('isDeleted', isEqualTo: false)
        .where('isAvailable', isEqualTo: true)
        .orderBy('nameLower')
        .startAt([q]).endAt(['$q\uf8ff']).limit(limit).get();

    return snap.docs.map(ProductModel.fromFirestore).toList();
  }

  // Admin
  Stream<List<ProductModel>> watchAdminProducts({int limit = 50}) {
    return _products
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
  }

  Future<String> create(ProductModel product) async {
    final now = DateTime.now();
    final docRef = _products.doc();
    final payload = product.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set({
      ...payload.toFirestore(),
      'nameLower': payload.name.toLowerCase(),
    });

    return docRef.id;
  }

  Future<void> update(ProductModel product) async {
    final now = DateTime.now();
    await _products.doc(product.id).set(
      {
        ...product.copyWith(updatedAt: now).toFirestore(),
        'nameLower': product.name.toLowerCase(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> softDelete(String productId) async {
    await _products.doc(productId).set(
      {
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
