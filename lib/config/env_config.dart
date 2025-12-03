/// Configuration class for environment variables
class EnvConfig {
  /// Supabase project URL
  static const String supabaseUrl = 'https://jvydvzshshrbbbhptckc.supabase.co';

  /// Supabase anonymous key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2eWR2enNoc2hyYmJ2aHB0Y2tjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1ODYwODAsImV4cCI6MjA4MDE2MjA4MH0.P-NYeycdQv05E-x8gz-X4D1ckPMNwwkZ8dBEqksK7i0';

  /// Validate that all required environment variables are present
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials are missing!');
    }
  }
}
