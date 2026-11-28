/// Build-time configuration of cloud sync, passed with
/// `--dart-define-from-file=config/sync.json` (see docs/SUPABASE_SETUP.md).
/// Without it the app behaves exactly as before: no account, no sync.
class SyncConfig {
  const SyncConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.enabled,
  });

  static const fromEnvironment = SyncConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    enabled: bool.fromEnvironment('SYNC_ENABLED'),
  );

  /// Project URL, e.g. `https://<ref>.supabase.co`.
  final String supabaseUrl;

  /// Public (anon/publishable) key. Never the service role key.
  final String supabaseAnonKey;

  /// Internal flag while sync is being tested.
  final bool enabled;

  bool get isAvailable =>
      enabled && supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
