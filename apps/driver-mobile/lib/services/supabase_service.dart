import 'package:supabase_flutter/supabase_flutter.dart';

// Values are injected at build/run time via --dart-define (see README.md),
// not read from a .env file, since this app ships as a static web build.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> initSupabase() async {
  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    // ignore: avoid_print
    print(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Pass them with --dart-define when running/building.',
    );
  }
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey);
}

SupabaseClient get supabase => Supabase.instance.client;
