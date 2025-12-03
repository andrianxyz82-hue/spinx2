/// Configuration class for environment variables
/// Uses --dart-define or --dart-define-from-file for configuration
class EnvConfig {
  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous key
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Initialize environment configuration
  /// No async load needed for dart-define
  static Future<void> initialize() async {
    // No-op for dart-define
  }

  /// Validate that all required environment variables are present
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found. '
        'Please run with --dart-define=SUPABASE_URL=... or --dart-define-from-file=.env',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found. '
        'Please run with --dart-define=SUPABASE_ANON_KEY=... or --dart-define-from-file=.env',
      );
    }
  }
}
