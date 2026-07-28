import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../models/category/category_model.dart';
import '../remote/firestore/category_firestore.dart';

class CategoryRepositoryImpl {
  CategoryRepositoryImpl(this._categoryFirestore);

  final CategoryFirestore _categoryFirestore;

  Stream<List<CategoryModel>> watchActiveCategories() =>
      _categoryFirestore.watchActiveCategories();

  Stream<List<CategoryModel>> watchAdminCategories() =>
      _categoryFirestore.watchAdminCategories();

  Future<(String?, Failure?)> create(CategoryModel category) async {
    try {
      final id = await _categoryFirestore.create(category);
      return (id, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<Failure?> update(CategoryModel category) async {
    try {
      await _categoryFirestore.update(category);
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }
}
