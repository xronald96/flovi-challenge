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

---

## Entry 3 — Both app scaffolds, and a git-workflow correction

**Prompt:** "continue, it is not necessary 4 hours if u can do it faster so continue please" — i.e.
keep moving without waiting on the literal 4-hour pacing. Built both apps back-to-back: installed
Flutter (not present on the machine) via Homebrew in the background while scaffolding the Vue app;
installed Tailwind v4 (`@tailwindcss/vite`, no separate config file needed) and `@supabase/supabase-js`;
built out auth composables, the request list/form/modal components, loading/empty/error states, and
toasts. In parallel, scaffolded the Flutter app (`flutter create --platforms=web,android`), added
`supabase_flutter`, and built the login screen, Available/My Gigs tabs, and a booking confirmation
sheet.

**What broke / had to be diagnosed without touching code by hand:**
- The machine's default Node (18.15, via an old nvm shim earlier in `PATH`) is too old for Vite 8 —
  `create-vite` and the dev server both crashed with a cryptic `styleText`/`CustomEvent` error. Fixed
  by pointing the project's dev-server launch config at a specific newer Node binary (22.19) directly
  at the `vite` entry script, bypassing both the stale `node` shim and `npm`'s own shebang resolution
  (which re-triggers the same old-Node problem even when you invoke a newer `npm` binary directly).
- First live preview of the dispatcher app rendered a blank page. Root cause: `createClient('', '')`
  when Supabase env vars are missing doesn't fail loudly — it's a real gap, since blank-on-misconfig
  is exactly the kind of failure that could show up again at deploy time if env vars aren't set on
  Vercel. Confirmed the actual UI (login screen, Google button) renders correctly once well-formed
  (placeholder) env values are present.
- Caught a real concurrency bug before it shipped: the booking mutation only guarded against races by
  filtering `eq('status', 'pending')` on the update, but Supabase doesn't error on a zero-row update —
  it would have silently shown "Gig booked!" even when another driver won the race. Fixed by chaining
  `.select()` on the update and checking the returned row count.
- `supabase_flutter` 2.16's API had moved past what training data assumed: `signInWithOAuth` lives in
  an extension on `GoTrueClient`, not as a named export, and `Supabase.initialize(anonKey: ...)` is
  deprecated in favor of `publishableKey`. Found both by grepping the actual installed package source
  in `~/.pub-cache` rather than guessing, and fixed the import/parameter accordingly.
- Removed the default Flutter counter-app widget test rather than rewriting it — it referenced a
  deleted class, and a test suite was explicitly scoped out of this build.

**Git workflow correction:** initially committed scaffolding directly to `main` (as Phase 0 was). When
asked to also set up GitHub login for "commits and PRs," the auto-mode safety classifier flagged
continuing to push straight to `main` as inconsistent with a PR-based ask. Asked the user directly
instead of routing around it: confirmed they want every change after the initial bootstrap commit to
go through a feature branch + PR, and — since nothing had been pushed to the (until-then completely
empty) GitHub repo yet — restructured the two already-made local commits onto their own branches
before pushing, rather than dumping them straight onto `main`. Hit a second, related wrinkle: a brand
new empty repo has no `main` to open a PR against, so one direct push was unavoidable to bootstrap it;
asked for and got explicit sign-off on that one-time exception rather than assuming it was fine. Then
hit a third: self-merging the first PR with no reviewer tripped the same classifier. Asked whether PRs
should be auto-merged (solo project, no other reviewer) or wait for manual review each time — user
chose auto-merge, so that's now the standing process for every subsequent phase.

**Verify:** `gh pr list --state all` shows PR #1 (dispatcher-web) and PR #2 (driver-mobile), both
merged into `main`; `flutter analyze` reports no issues; `npm run build` and `flutter build web` both
succeed.

**What remains:** Phase 1 (live Supabase project + Google OAuth client — needs the human's accounts),
then real end-to-end testing of both apps against that project, then deploy.
