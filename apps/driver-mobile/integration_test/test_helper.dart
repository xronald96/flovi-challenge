import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Real integration testing against a dedicated test Supabase project — no mocks. See
// apps/dispatcher-web/e2e/global-setup.ts for the Vue-side equivalent; this is the same
// test project and test user, reused here via --dart-define-from-file=test.env.json.
const _testSupabaseUrl = String.fromEnvironment('TEST_SUPABASE_URL');
const _testSupabaseAnonKey = String.fromEnvironment('TEST_SUPABASE_ANON_KEY');
const _testSupabaseServiceRoleKey = String.fromEnvironment('TEST_SUPABASE_SERVICE_ROLE_KEY');
const _testUserEmail = String.fromEnvironment('TEST_USER_EMAIL');
const _testUserPassword = String.fromEnvironment('TEST_USER_PASSWORD');

void _checkConfigured() {
  final missing = <String>[
    if (_testSupabaseUrl.isEmpty) 'TEST_SUPABASE_URL',
    if (_testSupabaseAnonKey.isEmpty) 'TEST_SUPABASE_ANON_KEY',
    if (_testSupabaseServiceRoleKey.isEmpty) 'TEST_SUPABASE_SERVICE_ROLE_KEY',
    if (_testUserEmail.isEmpty) 'TEST_USER_EMAIL',
    if (_testUserPassword.isEmpty) 'TEST_USER_PASSWORD',
  ];
  if (missing.isNotEmpty) {
    throw StateError(
      'Missing ${missing.join(', ')} — run flutter test '
      '--dart-define-from-file=test.env.json (copy test.env.example.json first).',
    );
  }
}

// The Dart Supabase client has no admin API (that's JS-client-only), so this hits the
// Auth Admin REST endpoint directly with the service-role key — the one HTTP call in
// this file that needs it, only ever run from test code, never from the app.
Future<void> _ensureTestUserExists() async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$_testSupabaseUrl/auth/v1/admin/users'));
    request.headers.set('apikey', _testSupabaseServiceRoleKey);
    request.headers.set('Authorization', 'Bearer $_testSupabaseServiceRoleKey');
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      'email': _testUserEmail,
      'password': _testUserPassword,
      'email_confirm': true,
    }));
    final response = await request.close();
    await response.drain<void>();
    // 200/201 = created, 422/400 = already exists — all fine for an idempotent setup.
    if (response.statusCode >= 500) {
      throw StateError('Failed to ensure test user exists: HTTP ${response.statusCode}');
    }
  } finally {
    client.close();
  }
}

/// Wipes relocation_requests. Uses the service-role REST endpoint directly: the schema
/// has no DELETE policy for authenticated users (by design), so the signed-in test
/// user's own client cannot do this — only the service role can.
Future<void> wipeRelocationRequests() async {
  final client = HttpClient();
  try {
    final request = await client.deleteUrl(
      Uri.parse('$_testSupabaseUrl/rest/v1/relocation_requests?id=not.is.null'),
    );
    request.headers.set('apikey', _testSupabaseServiceRoleKey);
    request.headers.set('Authorization', 'Bearer $_testSupabaseServiceRoleKey');
    final response = await request.close();
    await response.drain<void>();
  } finally {
    client.close();
  }
}

/// Directly sets a row's status via the service-role endpoint, bypassing the app —
/// used to simulate a concurrent booking by another driver mid-test.
Future<void> forceUpdateStatus(String id, {required String status, String? bookedBy}) async {
  final client = HttpClient();
  try {
    final request = await client.patchUrl(Uri.parse('$_testSupabaseUrl/rest/v1/relocation_requests?id=eq.$id'));
    request.headers.set('apikey', _testSupabaseServiceRoleKey);
    request.headers.set('Authorization', 'Bearer $_testSupabaseServiceRoleKey');
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({'status': status, 'booked_by': ?bookedBy}));
    final response = await request.close();
    await response.drain<void>();
  } finally {
    client.close();
  }
}

bool _initialized = false;

/// Initializes the real supabase_flutter client against the test project and signs in
/// as the dedicated test user with a real (not mocked) session. Idempotent per test
/// process — Supabase.initialize can only run once.
Future<void> initTestSupabase() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  _checkConfigured();
  await _ensureTestUserExists();

  if (!_initialized) {
    await Supabase.initialize(url: _testSupabaseUrl, publishableKey: _testSupabaseAnonKey);
    _initialized = true;
  }
  await Supabase.instance.client.auth.signInWithPassword(
    email: _testUserEmail,
    password: _testUserPassword,
  );
}

String get testUserId => Supabase.instance.client.auth.currentUser!.id;

Future<String> seedRelocationRequest({
  required String origin,
  required String destination,
  required String scheduledDate,
  String status = 'pending',
}) async {
  final row = await Supabase.instance.client
      .from('relocation_requests')
      .insert({
        'origin': origin,
        'destination': destination,
        'scheduled_date': scheduledDate,
        'status': status,
        'created_by': testUserId,
      })
      .select()
      .single();
  return row['id'] as String;
}

/// Polls by pumping real frames until [condition] is true, instead of
/// `pumpAndSettle()` — which times out here because the realtime client's websocket
/// keeps background timers scheduled indefinitely once a stream is subscribed.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  // 15s default: the realtime channel takes a moment to finish subscribing after a
  // fresh app boot, and a mutation that lands before that handshake completes can be
  // missed — the same class of flakiness seen in the Vue e2e suite's first mutation
  // after each fresh page load. A generous bounded timeout is the honest fix; it's
  // still bounded, so a genuine regression will still fail the test, just not on the
  // first ~200ms flake.
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (condition()) return;
  }
  throw TestFailure('pumpUntil: condition not met within $timeout');
}
