import '../../core/errors/error_handler.dart';
import '../../core/errors/failure.dart';
import '../models/product/product_model.dart';
import '../remote/firestore/product_firestore.dart';

class ProductRepositoryImpl {
  ProductRepositoryImpl(this._productFirestore);

  final ProductFirestore _productFirestore;

  Future<(List<ProductModel>?, Failure?)> getFeatured() async {
    try {
      final products = await _productFirestore.getFeatured();
      return (products, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<(List<ProductModel>?, Failure?)> getNewArrivals() async {
    try {
      final products = await _productFirestore.getNewArrivals();
      return (products, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<(List<ProductModel>?, Failure?)> getByCategory(String categoryId) async {
    try {
      final products = await _productFirestore.getByCategory(categoryId: categoryId);
      return (products, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<(List<ProductModel>?, Failure?)> search(String query) async {
    try {
      final products = await _productFirestore.searchByNamePrefix(query: query);
      return (products, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<(ProductModel?, Failure?)> getById(String productId) async {
    try {
      final product = await _productFirestore.getById(productId);
      if (product == null) {
        return (null, const NotFoundFailure(message: 'Product not found'));
      }
      return (product, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  // Admin
  Stream<List<ProductModel>> watchAdminProducts() =>
      _productFirestore.watchAdminProducts();

  Future<(String?, Failure?)> create(ProductModel product) async {
    try {
      final id = await _productFirestore.create(product);
      return (id, null);
    } catch (e) {
      return (null, ErrorHandler.handleException(e));
    }
  }

  Future<Failure?> update(ProductModel product) async {
    try {
      await _productFirestore.update(product);
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }

  Future<Failure?> softDelete(String productId) async {
    try {
      await _productFirestore.softDelete(productId);
      return null;
    } catch (e) {
      return ErrorHandler.handleException(e);
    }
  }
}
