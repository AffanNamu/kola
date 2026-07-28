import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String usd(num value) {
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return f.format(value);
  }

  static String withSymbol({
    required num value,
    required String symbol,
    int decimals = 2,
  }) {
    final f = NumberFormat.currency(symbol: symbol, decimalDigits: decimals);
    return f.format(value);
  }
}
