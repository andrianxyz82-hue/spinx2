import 'app_secrets.dart';

/// Configuration class for environment variables
/// Provides secure access to Supabase credentials from AppSecrets
class EnvConfig {
  /// Supabase project URL
  static String get supabaseUrl => AppSecrets.supabaseUrl;

  /// Supabase anonymous key
  static String get supabaseAnonKey => AppSecrets.supabaseAnonKey;

  /// Validate that all required environment variables are present
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'AppSecrets configuration invalid. '
        'Please ensure lib/config/app_secrets.dart contains valid credentials.',
      );
    }
  }
}
