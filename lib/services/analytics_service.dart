import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  static Future<void> logViewItem({
    required String productId,
    required String name,
    required double price,
  }) async {
    await _analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: name,
          price: price,
        ),
      ],
    );
  }

  static Future<void> logAddToCart({
    required String productId,
    required String name,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: name,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  static Future<void> logPurchase({
    required String orderId,
    required double value,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      value: value,
      currency: currency,
    );
  }
}
