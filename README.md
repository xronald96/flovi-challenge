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

> Status: 🚧 in progress — this README is updated at the end of each build phase. See
> [`PROMPT_LOG.md`](PROMPT_LOG.md) for the build history and [`docs/`](docs/) for the walkthrough
> and reflection.

## Live demo

| App | URL |
|-----|-----|
| Dispatcher web | _TBD_ |
| Driver mobile (web) | _TBD_ |

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

```bash
cd apps/driver-mobile
cp .env.example .env    # fill in SUPABASE_URL / SUPABASE_ANON_KEY (see env docs below)
flutter pub get
flutter run -d chrome
```

## Environment variables

| App | Variable | Where it comes from |
|-----|----------|----------------------|
| dispatcher-web | `VITE_SUPABASE_URL` | Supabase → Settings → API |
| dispatcher-web | `VITE_SUPABASE_ANON_KEY` | Supabase → Settings → API |
| driver-mobile | `SUPABASE_URL` | Supabase → Settings → API |
| driver-mobile | `SUPABASE_ANON_KEY` | Supabase → Settings → API |

## Deployment

_Filled in during Phase 5 — will include exact Vercel/Netlify steps for both apps, including how the
Flutter web build's static output is deployed since these hosts don't run `flutter build` natively._

## Demo flow

See [`docs/walkthrough.md`](docs/walkthrough.md) for the full 5-minute script.

## Prompt log & reflection

- [`PROMPT_LOG.md`](PROMPT_LOG.md) — key prompts, AI outputs, and decisions through the build.
- [`docs/reflection.md`](docs/reflection.md) — what worked, what broke, where AI got in the way.
