# driver-mobile

Flutter 3 app for drivers to browse and book relocation gigs. Ships as a **hosted Flutter web
build** rather than a native APK (see [`PROMPT_LOG.md`](../../PROMPT_LOG.md) for why). Part of the
[Flovi relocation workflow](../../README.md) monorepo — see the root README for the full project
overview, live URLs, and deployment steps for both apps.

## Stack

Flutter 3, Material widgets (no extra design-system package), `supabase_flutter` for auth/data/
realtime. No state-management library — screens call the Supabase client directly and hold their
own `StatefulWidget`/`StreamBuilder` state.

## Setup

```bash
cp env.example.json env.json   # fill in SUPABASE_URL / SUPABASE_ANON_KEY
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

Dart has no native `.env` support, so credentials are passed via `--dart-define-from-file` instead
of a `.env` file — see `lib/services/supabase_service.dart`.

## Project structure

```
lib/
  models/relocation_request.dart     Data model (mirrors the Vue app's TS type)
  services/supabase_service.dart     Client init, reads SUPABASE_URL/ANON_KEY via --dart-define
  screens/                           LoginScreen, HomeScreen, AvailableGigsTab, MyGigsTab
  widgets/                           StatusBadge, GigCard, BookingSheet
test/                                Unit tests — pure logic only (model parsing, StatusBadge)
integration_test/                    Real integration tests (see below)
macos/                               Desktop platform target, added solely to run integration_test
```

## Tests

```bash
flutter test test/                  # unit tests: no network, no dart-define needed
```

Integration tests run against a **dedicated test Supabase project**, not the live demo project, so
they can freely create/delete rows without touching real data:

```bash
cp test.env.example.json test.env.json   # fill in the test project's credentials and a
                                          # dedicated test user's email/password
./scripts/run_integration_tests.sh
```

A few things worth knowing if you touch this suite:

- **Why macOS, not web or an emulator:** `flutter test -d chrome` doesn't support the `integration_test`
  package for web targets. The alternative (`flutter drive` + `chromedriver`) hit a Chrome/chromedriver
  version mismatch on this machine plus a macOS Gatekeeper deprecation warning — fragile to depend on
  in CI long-term. macOS desktop runs the exact same platform-agnostic Dart widget/business logic with
  real networking and no browser/driver version to keep in sync, at the cost of not exercising
  web-specific rendering (not a concern for this suite's scope: data flow and business logic, not
  pixel-level layout).
- **Why plain `flutter_test` doesn't work here:** its `TestWidgetsFlutterBinding` returns HTTP 400 for
  every real network request and has no platform channel for `shared_preferences` (which
  `supabase_flutter` needs) — hence `integration_test`, which runs the real app.
- **Why the script runs each file separately:** `flutter test integration_test -d macos` (the whole
  directory in one invocation) fails after the first file — the previous run's app process doesn't
  tear down cleanly before the next one launches.
- `integration_test/screens/available_gigs_tab_booking_test.dart` is split out from
  `available_gigs_tab_test.dart` on purpose: reacting to a *live* realtime update turned out to be
  reliable as the first subscription made in a test process, but flaky after a couple of prior
  mount/dispose cycles in the same run. Isolating it avoided that churn; a longer timeout alone
  didn't fix it.

In CI this runs against the same test project via repo secrets, on a macOS runner (see
`.github/workflows/test.yml`).
