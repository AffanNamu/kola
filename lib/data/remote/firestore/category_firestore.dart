import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/category/category_model.dart';
import 'firestore_service.dart';

class CategoryFirestore {
  const CategoryFirestore();

  CollectionReference<Map<String, dynamic>> get _categories =>
      FirestoreService.col(FirestoreConstants.categories);

  Stream<List<CategoryModel>> watchActiveCategories() {
    return _categories
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryModel.fromFirestore).toList());
  }

  Future<List<CategoryModel>> getActiveCategories() async {
    final snap = await _categories
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map(CategoryModel.fromFirestore).toList();
  }

  // Admin
  Stream<List<CategoryModel>> watchAdminCategories() {
    return _categories
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryModel.fromFirestore).toList());
  }

  Future<String> create(CategoryModel category) async {
    final docRef = _categories.doc();
    final now = DateTime.now();
    final payload = category.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(payload.toFirestore());
    return docRef.id;
  }

  Future<void> update(CategoryModel category) async {
    await _categories.doc(category.id).set(
      category.copyWith(updatedAt: DateTime.now()).toFirestore(),
      SetOptions(merge: true),
    );
  }
}
