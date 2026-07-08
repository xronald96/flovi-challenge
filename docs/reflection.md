# Reflection

## What worked

- **Front-loading constraints in the first prompt paid off.** The initial brief specified the tech
  stack, folder layout, schema shape, UX requirements, and an explicit "what to skip" list before any
  code was written. That meant the planning phase only needed one pass (see `PROMPT_LOG.md` Entry 1)
  instead of several rounds of the AI guessing architecture and getting corrected — most of the
  "prompting skill" in this build was in that upfront structuring, not in later back-and-forth.
- **Small, verifiable increments caught real bugs before they compounded.** Committing scaffolding,
  then each app, then a realtime fix, as separate reviewable steps meant every bug below was caught
  within a few minutes of being introduced, against a small diff, instead of surfacing later buried
  in a much larger change.
- **Driving the actual apps in a real, authenticated browser (via the Chrome extension) instead of
  trusting the code** found two of the four real bugs below. Neither `flutter analyze` nor
  `npm run build` nor a code read would have caught the Google Client ID typo, the redirect URI
  mismatch, or the realtime stream bug — all three only showed up by actually clicking "Sign in" and
  "Confirm booking" against the live Supabase project and watching what happened.
- **Supabase's tradeoffs paid off exactly as expected.** Auth, Postgres, and Realtime out of one
  project meant zero custom backend code, and the realtime wiring (`postgres_changes` on the Vue
  side, `supabase_flutter`'s `.stream()` on the Flutter side) took minutes, not hours.

## What broke

- **A digit went missing when the Google Client ID was pasted into Supabase's dashboard**
  (`63152555322...` instead of `663152555322...`). Caught by inspecting the actual browser network
  log for the redirect to `accounts.google.com` rather than guessing from the vague "Redirecting…"
  UI state — the real request URL had the wrong client ID plainly visible in it.
- **`redirect_uri_mismatch`** — the Supabase callback URL wasn't yet whitelisted in the Google Cloud
  OAuth client. A separate, unrelated misconfiguration from the one above; both had to be fixed
  before login worked at all.
- **A real concurrency bug in the booking flow**: the original update only filtered
  `.eq('status', 'pending')` before writing, but Supabase doesn't error on a zero-row update — a
  losing bid in a booking race would have silently shown "Gig booked!" to the driver who didn't
  actually get it. Fixed by chaining `.select()` on the update and checking the returned row count
  before declaring success. Found by reasoning about the failure mode, not by reproducing it.
- **The driver app's "Available" list went stale after a booking** — a gig that had just been booked
  stayed visible until the tab was rebuilt. Traced to `supabase_flutter`'s `stream().eq()` correctly
  filtering the initial fetch but not reliably re-applying that filter to rows touched by incoming
  realtime events. Fixed by streaming the unfiltered table and filtering client-side in Dart on every
  emission instead of relying on the package's server-side filter — simpler and provably correct.
- **Post-deploy, OAuth broke again** — Supabase's redirect-URL matching turned out to be string-exact
  rather than prefix-aware: the Vue app's `redirectTo` (`https://dispatcher-web-ten.vercel.app`, no
  trailing slash) and Flutter's (`https://driver-mobile-delta.vercel.app/`, trailing slash from
  `Uri.base.toString()`) are two different strings, so the same allow-list entry didn't cover both
  until switched to a wildcard pattern. Diagnosed by literally reading the URL bar after a real login
  attempt landed on the wrong domain (`localhost:3000` — Supabase's fallback Site URL — instead of
  either production URL), not by inspecting the app code.

## Where AI got in the way

- **Training-data drift on a fast-moving dependency.** `supabase_flutter` had moved past what the
  model assumed twice in one session: `signInWithOAuth` lives on a `GoTrueClient` extension rather
  than a documented top-level method, and `Supabase.initialize(anonKey: ...)` is now deprecated in
  favor of `publishableKey`. Both were only resolved by grepping the actual installed package source
  in `~/.pub-cache` instead of trusting recalled API shape — a reminder that for anything Supabase- or
  Flutter-adjacent, the installed source is more current truth than the model's training data.
  Supabase's own dashboard terminology had drifted the same way (the "anon key" is now a
  `sb_publishable_...` key in newer projects), which cost a round-trip of the user hunting for a field
  that wasn't labeled what the AI expected.
- **A stale local toolchain silently broke the first scaffold attempt** — the default `node` on
  `PATH` was 18.15 (via an old nvm shim), too old for Vite 8's tooling, producing a cryptic
  `styleText`/`CustomEvent` crash with no indication the real cause was a Node version mismatch three
  layers down. This wasn't an AI reasoning failure exactly, but it's a class of problem AI-assisted
  development doesn't remove: environment drift still needs a human-legible error, and this one
  wasn't.
- **The git workflow needed correcting mid-build.** Left to its own judgment, the assistant defaulted
  to committing straight to `main` for the first few phases; only after being asked to also set up
  GitHub "commits and PRs" did a safety check flag that as inconsistent with the actual ask. Worth
  stating precisely for the sake of the prompting-strategy question this challenge asks about: this
  wasn't the AI proactively getting it right, it was a guardrail catching a default that needed
  explicit correction, which then had to be reconciled with an already-empty remote (see
  `PROMPT_LOG.md` Entry 3).

## Intentional scope cuts (not failures)

- No dispatcher/driver role system — any Google account can act as either. See
  `packages/shared/model.md` and `supabase/schema.sql` RLS policies.
- No native Android/iOS build — driver app ships as a hosted Flutter web build (the assignment
  explicitly allows this as equivalent to an APK).
- No pagination, offline support, push notifications, test suite, or custom CI — out of scope for a
  4-hour prompting exercise; see `AGENTS.md` for the full list and rationale.

## If there were another hour

Harden the RLS policies with an actual role check instead of "any authenticated user can update."
Right now a driver could edit a dispatcher's request and vice versa, which is fine for a demo but is
the first thing that would need to change before this touched real money or real freight — it would
need a `profiles` table with a `role` column and policies keyed off it, which was deliberately cut
from this build's scope (see above) but is the most load-bearing cut if the scope ever grew.

## What this says about how software development is changing

The bottleneck in this build was never "can the AI write the code" — every screen, query, and RLS
policy came out close to right on the first pass. The actual time went to three other things: (1)
external account configuration that no amount of code generation touches (Google Cloud Console,
Supabase dashboard fields, Vercel env vars), (2) verifying real behavior against real third-party
services (OAuth, realtime) that static analysis and even a build step can't catch, and (3) staying
close enough to the actual package versions in use to catch training-data drift instead of trusting
recalled API shape. That's a different skill than "prompting" in the conversational sense — it's
closer to the debugging and infrastructure literacy a senior engineer already has, just aimed at a
much faster code-generation loop. The job didn't get easier so much as it got compressed: less time
typing, the same or more time deciding what's actually true and clicking through account settings
that still require a human on the other end.
