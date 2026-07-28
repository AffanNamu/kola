class OrderNumber {
  OrderNumber._();

  static String generate() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    // KN-2026-0730-235959
    return 'KN-$y-$m$d-$h$min$s';
  }
}
