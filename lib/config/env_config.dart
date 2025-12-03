import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for environment variables
/// Provides secure access to Supabase credentials from .env file
class EnvConfig {
  /// Supabase project URL
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found in .env file. '
        'Please ensure .env file exists with required credentials.',
      );
    }
    return url;
  }

  /// Supabase anonymous key
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found in .env file. '
        'Please ensure .env file exists with required credentials.',
      );
    }
    return key;
  }

  /// Initialize environment configuration
  /// Must be called before accessing any environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Validate that all required environment variables are present
  static void validate() {
    try {
      // Access all required variables to trigger validation
      supabaseUrl;
      supabaseAnonKey;
    } catch (e) {
      throw Exception(
        'Environment configuration validation failed: $e\n'
        'Please check your .env file and ensure all required variables are set.',
      );
    }
  }
}
