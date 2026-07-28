import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order/order_model.dart';
import '../../../data/remote/firestore/order_firestore.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../auth/auth_provider.dart';

final orderFirestoreProvider = Provider<OrderFirestore>((ref) {
  return const OrderFirestore();
});

final orderRepositoryProvider = Provider<OrderRepositoryImpl>((ref) {
  return OrderRepositoryImpl(ref.read(orderFirestoreProvider));
});

final myOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.when(
    data: (u) {
      if (u == null) return const Stream.empty();
      final repo = ref.read(orderRepositoryProvider);
      return repo.watchMyOrders(u.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final adminOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.watchAdminOrders();
});
