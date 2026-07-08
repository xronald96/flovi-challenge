# AGENTS.md — Working rules for this repo

This repo is built for the Flovi AI Build Challenge: two connected apps (Vue 3 dispatcher web,
Flutter driver mobile), 100% AI-generated, shipped in a 4-hour budget. Any AI agent (or human)
working in this repo should follow these rules.

## Hard constraints

- **Zero manually-written code.** Every file in `apps/`, `packages/`, `supabase/` is AI-generated.
  The human's role is: prompting, reviewing, approving, and performing account/credential setup
  that no agent can do on their own (creating the Supabase project, Google Cloud OAuth client,
  hosting account linkage). Those are configuration actions, not code.
- **No huge steps.** Work in small, logically-grouped increments. Each increment should be
  independently verifiable (dev server runs, a specific flow works) before moving to the next.
- **Small, logically-grouped commits.** Do not squash the whole build into one commit. Commit
  scaffolding separately from features; commit each app's auth, list, create, edit, booking flows
  as their own steps where practical.
- **After every implementation step, report:** what changed, why it changed, how to verify it, and
  what remains. This is not optional — it's how the human stays in the loop without reading every
  line of generated code.

## Product rules

- Both apps operate on **one shared data model**: the `relocation_requests` table defined in
  `supabase/schema.sql`, mirrored in a short spec at `packages/shared/model.md`. Do not let the two
  apps' local types drift from that spec — update the spec first, then both apps.
- Prefer working software over perfect architecture. Skip: RBAC/roles, pagination, offline support,
  push notifications, native Android/iOS builds, test suites, custom CI. These are itemized as
  explicit scope cuts in `docs/reflection.md` — don't silently add them back "for completeness."
  If a real need for one of them surfaces, stop and flag it rather than building it inline.
- Every screen that fetches or mutates data needs loading, empty, error, and success states. This
  is a stated requirement, not a nice-to-have — don't ship a bare happy path.
- Basic validation on all forms (required fields, sane date constraints) — client-side is enough,
  backed by Postgres `not null` constraints as the last line of defense.
- Tailwind CSS for the Vue app; no additional component/UI libraries. Flutter Material widgets for
  the driver app; no additional design-system packages. Keep the dependency list short and
  intentional — this is a scoring criterion ("did you avoid unnecessary libraries"), not a style
  preference.
- Driver app's deployment target is **Flutter web** (a hosted web build), not a native APK — see
  `PROMPT_LOG.md` for the rationale. Design it mobile-first regardless.

## Housekeeping

- Keep `PROMPT_LOG.md` updated as you go — key prompts, what came back, what was changed and why.
  Don't reconstruct it at the end from memory.
- Keep `README.md` accurate to the current state of the repo (setup steps, env vars, deploy
  instructions) — treat stale docs as a bug.
- Secrets (Supabase URL/anon key, Google client ID) live in `.env` files that are gitignored; only
  `.env.example` files with placeholder values are committed.
