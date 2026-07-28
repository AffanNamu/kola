class SupportLinks {
  SupportLinks._();

  // TODO: Replace with your real contacts
  static const String supportEmail = 'support@kolanut.com';
  static const String whatsappNumber = '+2340000000000';

  static String whatsappUrl([String message = 'Hello Kolanut Support']) {
    final n = whatsappNumber.replaceAll('+', '');
    final m = Uri.encodeComponent(message);
    return 'https://wa.me/$n?text=$m';
  }

  static String emailUrl() => 'mailto:$supportEmail';
}
