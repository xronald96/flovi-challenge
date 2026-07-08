# AGENTS.md — Project reference

Two connected apps simulating a relocation dispatch workflow: **dispatcher-web** (Vue) for creating
and managing relocation requests, **driver-mobile** (Flutter web) for browsing and booking them.
Built for the Flovi AI Build Challenge (100% AI-generated); this file is meant to give any agent
(or future you) enough context to keep working on it without re-deriving the architecture from
scratch. See `PROMPT_LOG.md` for the full build history and every bug hit along the way, and
`docs/reflection.md` for the honest retrospective.

## Architecture

```
apps/dispatcher-web/   Vue 3 + Vite 8 + Tailwind v4 (@tailwindcss/vite, no config file needed)
  src/lib/supabase.ts                    Supabase client (reads VITE_SUPABASE_URL/ANON_KEY)
  src/types/relocation.ts                TS model + status labels/badge colors
  src/composables/useAuth.ts             Module-level singleton session state (no Pinia)
  src/composables/useRelocationRequests.ts  List/create/update + realtime channel subscription
  src/components/{LoginView,Modal,RequestForm,RequestList,StatusBadge}.vue
  src/App.vue                            Orchestrates everything — no router, just v-if branching

apps/driver-mobile/    Flutter 3, web build target (android/ scaffolded but not deployed)
  lib/models/relocation_request.dart     Dart model, mirrors the TS one
  lib/services/supabase_service.dart     Init reads SUPABASE_URL/ANON_KEY via --dart-define
  lib/screens/{login_screen,home_screen,available_gigs_tab,my_gigs_tab}.dart
  lib/widgets/{status_badge,gig_card,booking_sheet}.dart

packages/shared/model.md   Canonical field/status spec both apps' local models must match
supabase/schema.sql        Single source of truth: table, RLS, trigger, realtime publication
```

## Data model

One table, `relocation_requests` (see `supabase/schema.sql` for the authoritative definition and
`packages/shared/model.md` for the plain-language spec): `origin`, `destination`, `scheduled_date`,
`notes`, `status` (enum: `pending`/`booked`/`completed`/`cancelled`), `created_by`, `booked_by`,
timestamps. No roles table — any authenticated user can read all rows, insert as themselves, and
update any row (RLS policies in `schema.sql`). If you ever add real dispatcher/driver roles, that
policy is the first thing to tighten (see "If there were another hour" in `docs/reflection.md`).

## Live deployment

| App | URL | Notes |
|-----|-----|-------|
| dispatcher-web | https://dispatcher-web-ten.vercel.app | Vercel project `xronald96s-projects/dispatcher-web`, git-linked; env vars set via `vercel env add` |
| driver-mobile | https://driver-mobile-delta.vercel.app | Vercel project `driver-mobile`, **not** git-linked — redeploy manually (see below) |

Both point at the same Supabase project (`bzfkaeyhpbvlqekzggxw`).

**To redeploy dispatcher-web:** push to `main`, or `cd apps/dispatcher-web && vercel --prod`.

**To redeploy driver-mobile:** it's a static export, not a git-integrated build —
```bash
cd apps/driver-mobile
flutter build web --dart-define-from-file=env.json
cd build/web && vercel --prod --name driver-mobile
```

## Known gotchas (read before touching auth or realtime)

- **Supabase Redirect URLs must be wildcards, not exact strings.** Vite's `window.location.origin`
  has no trailing slash; Flutter web's `Uri.base.toString()` does. Supabase's redirect matching is
  string-exact, so use `https://your-app.vercel.app/*` in Authentication → URL Configuration, not the
  bare URL — otherwise login silently falls back to whatever `Site URL` is configured instead of
  erroring.
- **`supabase_flutter`'s `.stream().eq()` does not reliably re-apply its filter to rows changed by
  incoming realtime events** (only the initial fetch is filtered correctly). Both `AvailableGigsTab`
  and `MyGigsTab` stream the *whole* table and filter client-side in Dart for this reason — don't
  "simplify" that back to a server-side `.eq()` without re-testing a live update while the tab stays
  mounted.
- **The local dev Node on `PATH` may be too old for Vite** (was 18.x via a stale nvm shim at the
  start of this build; Vite 8 needs 20.19+/22.12+). `.claude/launch.json`'s dispatcher-web config
  points at a specific newer Node binary directly at the `vite` entry script to route around this —
  if that path no longer exists on a given machine, find a Node ≥20.19 and update the config rather
  than assuming `vite`/`npm` on `PATH` will work.
- **Driver app secrets are not a `.env` file.** Dart has no native `.env` support; credentials go in
  a gitignored `apps/driver-mobile/env.json` (see `env.example.json`), passed via
  `--dart-define-from-file=env.json` to both `flutter run` and `flutter build web`.
- **Google OAuth consent screen is in "Testing" mode** — only accounts added as test users in the
  Google Cloud OAuth client can log in. Add new demo accounts there before a live walkthrough.

## Working conventions

- **Feature branch + PR for every change**, squash-merged, branch deleted after — established mid-
  build at the user's request (see `PROMPT_LOG.md` Entry 3). Don't push straight to `main`.
- **Small, logically-grouped commits/PRs** — one concern per PR, not a grab-bag.
- **Keep `PROMPT_LOG.md` and `README.md` current.** If a change makes a documented setup step,
  gotcha, or URL wrong, treat that as part of the change, not a follow-up.
- **Every screen that fetches or mutates data needs loading, empty, error, and success states** —
  this was a stated requirement for the original build and is just good practice going forward.
- **Keep the dependency list intentional.** No new state-management/UI/component libraries without
  a concrete reason — both apps currently have zero extra libraries beyond the Supabase client and
  (Vue side) Tailwind.
- **After a non-trivial change, verify it actually works** (dev server / `flutter run -d chrome`,
  and for anything auth- or realtime-related, a real login — the sandboxed preview browser can't
  complete third-party OAuth, so that needs either a real browser or the Chrome extension with the
  user's go-ahead).
