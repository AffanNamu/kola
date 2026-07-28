import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/remote/firestore/category_firestore.dart';
import '../../../data/repositories/category_repository_impl.dart';

final categoryFirestoreProvider = Provider<CategoryFirestore>((ref) {
  return const CategoryFirestore();
});

final categoryRepositoryProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(ref.read(categoryFirestoreProvider));
});

final activeCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.watchActiveCategories();
});

final adminCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.watchAdminCategories();
});
