import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../../../services/local_storage_service.dart';
import '../../../data/local/database/app_database.dart';

final cartItemsStreamProvider = StreamProvider<List<CartItemModel>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCartItems().map((rows) {
    return rows
        .map(
          (r) => CartItemModel(
            id: r.id,
            productId: r.productId,
            productName: r.productName,
            productImage: r.productImage,
            price: r.price,
            quantity: r.quantity,
            variantId: r.variantId,
            variantName: r.variantName,
            sku: r.sku,
            maxStock: r.maxStock,
            addedAt: r.addedAt,
          ),
        )
        .toList();
  });
});

final cartCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCartItems().map((rows) {
    return rows.fold<int>(0, (sum, r) => sum + r.quantity);
  });
});

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<void>>((ref) {
  return CartController(ref);
});

class CartController extends StateNotifier<AsyncValue<void>> {
  CartController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  AppDatabase get _db => ref.read(appDatabaseProvider);

  String _makeId(String productId, String? variantId) {
    final v = (variantId == null || variantId.isEmpty) ? 'default' : variantId;
    return '$productId|$v';
  }

  Future<void> addToCart({
    required String productId,
    required String name,
    required String image,
    required double price,
    int quantity = 1,
    String? variantId,
    String variantName = '',
    String sku = '',
    int maxStock = 0,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = _makeId(productId, variantId);
      // If exists -> increment
      final current = await (_db.select(_db.cartItems)..where((t) => t.id.equals(id))).getSingleOrNull();
      final newQty = (current?.quantity ?? 0) + quantity;
      await _db.upsertCartItem(
        CartItemsCompanion.insert(
          id: id,
          productId: productId,
          productName: name,
          productImage: image,
          price: price,
          quantity: newQty,
          maxStock: maxStock,
          variantId: Value(variantId),
          variantName: Value(variantName),
          sku: Value(sku),
          addedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> setQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await remove(id);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.updateQuantity(id, quantity);
    });
  }

  Future<void> remove(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.removeItem(id);
    });
  }

  Future<void> clear() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.clearCart();
    });
  }
}
