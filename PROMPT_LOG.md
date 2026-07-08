# Prompt Log

A running trace of the key prompts used to build this project, what came back, and what changed as
a result. Entries are added as the build progresses, not reconstructed afterward. Full prompt text is
summarized where long; decisions and deltas are kept verbatim where they matter.

---

## Entry 1 — Kickoff & planning (pre-code)

**Prompt (summarized):** Provided the Flovi AI Build Challenge PDF and a detailed brief: build a Vue 3
dispatcher web app and a Flutter driver mobile app, both backed by Supabase (auth + DB + realtime),
sharing one relocation-request data model, with Google OAuth, a specific monorepo layout
(`apps/`, `packages/shared/`, `docs/`, `supabase/`), and delivery artifacts (prompt log, walkthrough,
reflection). Explicit instruction: **do not write any application code yet** — first return an
implementation strategy, monorepo structure, Supabase schema, phased plan, risks, and the first files
to be generated, for review before implementation starts.

**What came back:** A full written plan (see `docs/` and this repo's git history for the plan
artifact) covering:
- 4-hour phase breakdown (scaffolding → Supabase/OAuth setup → dispatcher app → driver app →
  realtime wiring → deploy → docs polish)
- Monorepo structure matching the requested layout
- Supabase schema: single `relocation_requests` table, a `relocation_status` enum
  (`pending`/`booked`/`completed`/`cancelled`), RLS policies, realtime publication
- Explicit "what's skipped" list to pre-empt scope creep (no RBAC, no pagination, no native mobile
  build, no test suite, no custom CI)

**Key decision surfaced and accepted:** ship the driver app as a **hosted Flutter web build** rather
than a native Android APK. The assignment explicitly allows either; a web build removes APK
signing/emulator risk from a 4-hour budget with no rubric downside, and still satisfies "clean,
mobile-first Flutter UI" since the layout is designed mobile-first and is fully responsive.

**Why this matters for prompting strategy:** the brief front-loaded every constraint (tech stack,
folder layout, schema shape, UX requirements, what to skip) into one structured request rather than
letting the agent freelance the architecture — this is why the planning turn only needed one pass
before approval, instead of several rounds of back-and-forth.

---

## Entry 2 — Repo scaffolding

**Prompt:** Proceed with Phase 0 of the approved plan: generate `.gitignore`, `AGENTS.md`,
`PROMPT_LOG.md` (this file), `README.md` skeleton, `docs/walkthrough.md` and `docs/reflection.md`
skeletons, `supabase/schema.sql`, and `packages/shared/model.md`.

**What came back:** All seven files generated per the plan. `AGENTS.md` encodes the working rules
(no manual code, small commits, explicit skip-list, per-step reporting). `supabase/schema.sql`
implements the single-table model with RLS and a realtime publication. `packages/shared/model.md`
is the cross-language source of truth for the data shape (Vue/TS and Flutter/Dart each implement
their own typed model against this spec, since sharing runtime code across the two languages isn't
practical here).

**Verify:** `ls` the repo root and confirm the structure matches `docs/` in the approved plan; read
`supabase/schema.sql` and confirm it matches the schema decided in planning.

**What remains:** initial git commit, then Phase 1 (Supabase + Google OAuth account setup, which
needs the human's Supabase/Google Cloud accounts) in parallel with scaffolding the Vue app.
