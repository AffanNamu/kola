import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product/product_model.dart';
import '../../../data/remote/firestore/product_firestore.dart';
import '../../../data/repositories/product_repository_impl.dart';
import 'product_state.dart';

final productFirestoreProvider = Provider<ProductFirestore>((ref) {
  return const ProductFirestore();
});

final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(ref.read(productFirestoreProvider));
});

final featuredProductsProvider =
    StateNotifierProvider<FeaturedProductsNotifier, ProductState>((ref) {
  return FeaturedProductsNotifier(ref.read(productRepositoryProvider));
});

final newArrivalsProvider =
    StateNotifierProvider<NewArrivalsNotifier, ProductState>((ref) {
  return NewArrivalsNotifier(ref.read(productRepositoryProvider));
});

final categoryProductsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, categoryId) async {
    final repo = ref.read(productRepositoryProvider);
    final (products, failure) = await repo.getByCategory(categoryId);
    if (failure != null) throw Exception(failure.message);
    return products ?? [];
  },
);

final productDetailProvider = FutureProvider.family<ProductModel?, String>(
  (ref, productId) async {
    final repo = ref.read(productRepositoryProvider);
    final (product, failure) = await repo.getById(productId);
    if (failure != null) throw Exception(failure.message);
    return product;
  },
);

// Admin stream
final adminProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return repo.watchAdminProducts();
});

class FeaturedProductsNotifier extends StateNotifier<ProductState> {
  FeaturedProductsNotifier(this._repo) : super(const ProductState.initial());

  final ProductRepositoryImpl _repo;

  Future<void> load() async {
    state = const ProductState.loading();
    final (products, failure) = await _repo.getFeatured();
    if (failure != null) {
      state = ProductState.error(failure.message);
      return;
    }
    state = ProductState.loaded(products ?? []);
  }
}

class NewArrivalsNotifier extends StateNotifier<ProductState> {
  NewArrivalsNotifier(this._repo) : super(const ProductState.initial());

  final ProductRepositoryImpl _repo;

  Future<void> load() async {
    state = const ProductState.loading();
    final (products, failure) = await _repo.getNewArrivals();
    if (failure != null) {
      state = ProductState.error(failure.message);
      return;
    }
    state = ProductState.loaded(products ?? []);
  }
}
