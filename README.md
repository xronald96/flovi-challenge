# Flovi Relocation Workflow — AI Build Challenge

Two connected apps simulating a relocation dispatch workflow, built end-to-end with AI-generated
code in a 4-hour sprint:

- **Dispatcher web app** (`apps/dispatcher-web`) — Vue 3 + Vite + Tailwind CSS. Dispatchers log in
  with Google, create relocation requests, and track/edit their status.
- **Driver mobile app** (`apps/driver-mobile`) — Flutter 3, deployed as a hosted web build. Drivers
  log in with Google, browse unbooked gigs, book with one tap, and see their booked gigs.

Both apps share one Supabase project (Postgres + Auth + Realtime) and one data model, defined in
[`supabase/schema.sql`](supabase/schema.sql) and documented in
[`packages/shared/model.md`](packages/shared/model.md).

See [`PROMPT_LOG.md`](PROMPT_LOG.md) for the build history and [`docs/`](docs/) for the walkthrough
and reflection.

## Live demo

| App | URL |
|-----|-----|
| Dispatcher web | https://dispatcher-web-ten.vercel.app |
| Driver mobile (web) | https://driver-mobile-delta.vercel.app |

Both are backed by the same live Supabase project. Sign in with any Google account (the OAuth
consent screen is currently in "Testing" mode, so only accounts added as test users in the Google
Cloud OAuth client can log in — ask for access if needed).

## Repo structure

```
apps/
  dispatcher-web/   Vue 3 + Vite + Tailwind
  driver-mobile/    Flutter 3 (web build target)
packages/
  shared/           Cross-app data model spec
docs/
  walkthrough.md    5-minute demo script
  reflection.md     What worked, what broke, where AI got in the way
supabase/
  schema.sql        Full DB schema, RLS policies, realtime publication
```

## Tech stack & why

- **Vue 3 + Vite + Tailwind** for the dispatcher app — fast dev loop, utility CSS keeps styling
  quick without a component library.
- **Flutter 3, web build** for the driver app — one clean mobile-first UI, deployed as a static web
  build rather than a native APK (the assignment explicitly allows either; the web build removes
  signing/emulator risk from a 4-hour budget with no scoring downside).
- **Supabase** for auth (Google OAuth), Postgres, and Realtime — covers auth + DB + near-real-time
  sync out of the box, no custom backend needed.
- **Vercel/Netlify** for static hosting of both apps.

See [`docs/reflection.md`](docs/reflection.md) for the full list of intentional scope cuts (no
role-based access control, no pagination, no native mobile build, no test suite).

## Setup

### 1. Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. In the SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql).
3. Under **Authentication → Providers**, enable **Google** (requires a Google Cloud OAuth client —
   see below), and add your dev/prod URLs under **Authentication → URL Configuration**.
4. Copy your project's **URL** and **anon public key** from **Settings → API** — you'll need them
   for both apps' env files.

### 2. Google OAuth client

1. In [Google Cloud Console](https://console.cloud.google.com/), create an OAuth 2.0 Client ID
   (Web application type).
2. Add the Supabase callback URL (`https://<project-ref>.supabase.co/auth/v1/callback`) as an
   authorized redirect URI.
3. Paste the Client ID and Secret into Supabase's Google provider settings.
4. While the OAuth consent screen is in "Testing" mode, add every Google account that needs to log
   in (including your own, for the demo) as a test user.

### 3. Dispatcher web app

```bash
cd apps/dispatcher-web
cp .env.example .env   # fill in VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY
npm install
npm run dev
```

### 4. Driver mobile app

Dart has no native `.env` support, so credentials are passed at build/run time via
`--dart-define-from-file` instead of a `.env` file:

```bash
cd apps/driver-mobile
cp env.example.json env.json   # fill in SUPABASE_URL / SUPABASE_ANON_KEY
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

## Environment variables

| App | Variable | Where it comes from |
|-----|----------|----------------------|
| dispatcher-web | `VITE_SUPABASE_URL` | Supabase → Settings → API |
| dispatcher-web | `VITE_SUPABASE_ANON_KEY` | Supabase → Settings → API |
| driver-mobile | `SUPABASE_URL` (in `env.json`) | Supabase → Settings → API |
| driver-mobile | `SUPABASE_ANON_KEY` (in `env.json`) | Supabase → Settings → API |

## Deployment

Both apps are static builds, deployed to Vercel as two separate projects under the same account.

### Dispatcher web (Vercel)

```bash
cd apps/dispatcher-web
vercel --prod   # first run links/creates the project; set env vars once via:
vercel env add VITE_SUPABASE_URL production
vercel env add VITE_SUPABASE_ANON_KEY production
```

Vercel auto-detects the Vite build (`npm run build` → `dist/`) — no extra config needed beyond the
two env vars above (Settings → Environment Variables in the Vercel dashboard, or the CLI commands
above).

### Driver mobile (Vercel, static Flutter web build)

Vercel/Netlify have no native Flutter buildpack, so the web build happens locally/in CI first, and
only the compiled static output is deployed:

```bash
cd apps/driver-mobile
flutter build web --dart-define-from-file=env.json
cd build/web
vercel --prod --name driver-mobile
```

### After deploying (both apps)

Add the production URLs to Supabase → Authentication → URL Configuration → **Redirect URLs**. Use a
wildcard (`https://your-app.vercel.app/*`) rather than an exact string — Flutter web's OAuth
redirect includes a trailing slash while Vite's doesn't, and Supabase's redirect matching is
string-exact unless you use a glob pattern. Without this, Google login silently falls back to
whatever `Site URL` is configured (often `http://localhost:3000`) instead of erroring, which is a
confusing failure mode to debug blind — check the browser's address bar after picking a Google
account if login ever seems to "do nothing" after deploying to a new URL.

## Demo flow

See [`docs/walkthrough.md`](docs/walkthrough.md) for the full 5-minute script.

## Prompt log & reflection

- [`PROMPT_LOG.md`](PROMPT_LOG.md) — key prompts, AI outputs, and decisions through the build.
- [`docs/reflection.md`](docs/reflection.md) — what worked, what broke, where AI got in the way.
