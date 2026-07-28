class SupabaseConstants {
  SupabaseConstants._();

  // You set this via GitHub Actions secret by generating a file (recommended),
  // or hardcode for now and replace later.
  //
  // Example: https://<project-ref>.functions.supabase.co
  static const String verifyBaseUrl = String.fromEnvironment(
    'SUPABASE_VERIFY_BASE_URL',
    defaultValue: '',
  );
}
