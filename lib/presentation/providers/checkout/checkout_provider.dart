import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/order_constants.dart';
import '../../../core/utils/order_number.dart';
import '../../../data/models/order/order_item_model.dart';
import '../../../data/models/order/order_model.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../auth/auth_provider.dart';
import '../cart/cart_provider.dart';
import '../order/order_provider.dart';

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, AsyncValue<String?>>((ref) {
  return CheckoutController(ref);
});

class CheckoutController extends StateNotifier<AsyncValue<String?>> {
  CheckoutController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> createOrderFromCart() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) throw Exception('Please login to checkout.');

      final cartItems = await ref.read(cartItemsStreamProvider.future);
      if (cartItems.isEmpty) throw Exception('Cart is empty.');

      final items = cartItems
          .map(
            (c) => OrderItemModel(
              productId: c.productId,
              productName: c.productName,
              productImage: c.productImage,
              variantId: c.variantId,
              variantName: c.variantName,
              price: c.price,
              quantity: c.quantity,
              sku: c.sku,
            ),
          )
          .toList();

      final subtotal = items.fold<double>(0, (sum, x) => sum + x.total);
      final shippingFee = 0.0;
      final discount = 0.0;
      final total = subtotal + shippingFee - discount;

      final order = OrderModel(
        id: '',
        orderNumber: OrderNumber.generate(),
        userId: user.uid,
        status: OrderConstants.pendingPayment,
        items: items,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        total: total,
        paymentGateway: '',
        paymentReference: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(orderRepositoryProvider);
      final (orderId, failure) = await repo.create(order);
      if (failure != null) throw Exception(failure.message);

      await ref.read(cartControllerProvider.notifier).clear();
      ref.invalidate(myOrdersProvider);

      return orderId;
    });
  }
}
