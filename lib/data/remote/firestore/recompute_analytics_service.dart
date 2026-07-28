import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../models/analytics/admin_analytics_model.dart';
import 'admin_analytics_firestore.dart';
import 'firestore_service.dart';

class RecomputeAnalyticsService {
  RecomputeAnalyticsService({required this.analyticsFs});
  final AdminAnalyticsFirestore analyticsFs;

  Future<void> run() async {
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 30));

    final ordersSnap = await FirestoreService.col(FirestoreConstants.orders)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    int orders30d = 0;
    double revenue30d = 0.0;
    final topMap = <String, ({String name, int qty})>{};

    for (final doc in ordersSnap.docs) {
      final data = doc.data();

      // count only paid-ish orders
      final status = (data['status'] ?? '').toString();
      final isPaid = status == 'paid' ||
          status == 'confirmed' ||
          status == 'processing' ||
          status == 'packed' ||
          status == 'shipped' ||
          status == 'delivered';

      if (!isPaid) continue;

      orders30d += 1;
      revenue30d += (data['total'] as num?)?.toDouble() ?? 0.0;

      final items = (data['items'] as List?) ?? [];
      for (final raw in items) {
        final m = (raw as Map).cast<String, dynamic>();
        final pid = (m['productId'] ?? '').toString();
        final name = (m['productName'] ?? '').toString();
        final qty = (m['quantity'] as num?)?.toInt() ?? 0;
        if (pid.isEmpty) continue;

        final existing = topMap[pid];
        if (existing == null) {
          topMap[pid] = (name: name, qty: qty);
        } else {
          topMap[pid] = (name: existing.name, qty: existing.qty + qty);
        }
      }
    }

    // customers count
    final usersSnap = await FirestoreService.col(FirestoreConstants.users)
        .where('role', isEqualTo: 'customer')
        .get();
    final customers = usersSnap.size;

    // products count (not deleted)
    final productsSnap = await FirestoreService.col(FirestoreConstants.products)
        .where('isDeleted', isEqualTo: false)
        .get();
    final products = productsSnap.size;

    final topProducts = topMap.entries
        .map((e) => TopProduct(productId: e.key, name: e.value.name, qty: e.value.qty))
        .toList()
      ..sort((a, b) => b.qty.compareTo(a.qty));

    final model = AdminAnalyticsModel(
      orders30d: orders30d,
      revenue30d: revenue30d,
      customers: customers,
      products: products,
      topProducts: topProducts.take(10).toList(),
      updatedAtIso: now.toIso8601String(),
    );

    await analyticsFs.set(model);
  }
}
