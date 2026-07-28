class PaymentMessages {
  PaymentMessages._();

  static const String missingVerifyUrl =
      'Missing Supabase verify base URL. Set SUPABASE_VERIFY_BASE_URL in GitHub secrets.';
  static const String verifyFailed =
      'Payment verification failed. Please contact support.';
}
