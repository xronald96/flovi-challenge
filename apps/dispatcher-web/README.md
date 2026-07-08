# dispatcher-web

Vue 3 + Vite + Tailwind CSS app for creating and managing relocation requests. Part of the
[Flovi relocation workflow](../../README.md) monorepo — see the root README for the full project
overview, live URLs, and deployment steps for both apps.

## Stack

Vue 3 (`<script setup>`, no router — a single `App.vue` branches on auth state), Tailwind CSS v4
(`@tailwindcss/vite`, no config file needed), `@supabase/supabase-js` for auth/data/realtime. No
state-management library — auth session and the request list are each a small composable
(`src/composables/`) holding module-level reactive state.

## Setup

```bash
cp .env.example .env   # fill in VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY
npm install
npm run dev
```

Requires Node 20.19+/22.12+ (Vite 8). See [`AGENTS.md`](../../AGENTS.md) if `vite`/`npm` on your
`PATH` resolve to an older Node — this repo's `.claude/launch.json` works around exactly that.

## Scripts

| Command | What it does |
|---|---|
| `npm run dev` | Local dev server |
| `npm run build` | Type-checks (`vue-tsc`) then builds for production |
| `npm run preview` | Serves the production build locally |
| `npm test` | Vitest unit tests — pure logic only (form validation, status maps), no network |
| `npm run test:watch` | Vitest in watch mode |
| `npm run test:e2e` | Playwright e2e against a **dedicated test Supabase project** — see below |

## Project structure

```
src/
  lib/supabase.ts                    Supabase client
  types/relocation.ts                Data model + status label/badge maps
  composables/useAuth.ts             Session state, sign in/out
  composables/useRelocationRequests.ts  List, create, update, realtime subscription
  components/                        LoginView, RequestList, RequestForm, StatusBadge, Modal
  App.vue                            Top-level orchestration
e2e/                                 Playwright suite (see below)
```

## e2e tests

`npm run test:e2e` runs real end-to-end tests against a **second, dedicated Supabase project**
(same `supabase/schema.sql`), not the live demo project — so tests never touch real data and can
freely create/delete rows. To run locally:

```bash
cp .env.test.example .env.test   # fill in the test project's URL, anon key, service-role key,
                                  # and a dedicated test user's email/password
npm run test:e2e
```

`e2e/global-setup.ts` mints a real session for that test user via Supabase's service-role Admin
API — this is the one thing that can't be automated for real (a human clicking through Google's
own consent screen), so it's the only part of the flow that isn't exercised exactly as production
auth works. Everything after that — list, create, edit, validation, realtime sync across two
browser contexts — runs for real against Postgres/Realtime, no mocks.

In CI this runs against the same test project via repo secrets (see
`.github/workflows/test.yml`).
