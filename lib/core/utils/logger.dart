class Logger {
  Logger._();

  static void d(String message) {
    // keep minimal for free-tier, no external logging
    // ignore: avoid_print
    print('[DEBUG] $message');
  }

  static void e(String message) {
    // ignore: avoid_print
    print('[ERROR] $message');
  }
}
