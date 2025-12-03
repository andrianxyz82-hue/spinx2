/// App Secrets Configuration
/// This file contains sensitive credentials and should NOT be committed to version control.
/// It is generated automatically during CI/CD builds.
class AppSecrets {
  // Default values for development - REPLACE THESE with your actual keys for local dev
  // For production/CI, these will be overwritten by the build script
  static const String supabaseUrl = 'https://jvydvzshshrbbbhptckc.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2eWR2enNoc2hyYmJ2aHB0Y2tjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1ODYwODAsImV4cCI6MjA4MDE2MjA4MH0.P-NYeycdQv05E-x8gz-X4D1ckPMNwwkZ8dBEqksK7i0';
}
