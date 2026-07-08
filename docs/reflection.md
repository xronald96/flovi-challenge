# Reflection

_Status: skeleton — filled in honestly at the end of the build, once there's real experience to
reflect on. Placeholders below mark what each section needs to cover._

## What worked

_TBD — call out specific moments where AI-assisted prompting was clearly faster/better than manual
coding would have been, not a generic "AI is amazing."_

## What broke

_TBD — specific failures: wrong assumptions, OAuth/redirect misconfigurations, realtime edge cases,
anything the first generated attempt got wrong. Include how it was diagnosed and fixed without
touching code by hand._

## Where AI got in the way

_TBD — moments of over-engineering, wrong defaults, or plausible-but-incorrect suggestions that had
to be pushed back on._

## Intentional scope cuts (not failures)

- No dispatcher/driver role system — any Google account can act as either. See
  `packages/shared/model.md` and `supabase/schema.sql` RLS policies.
- No native Android/iOS build — driver app ships as a hosted Flutter web build (the assignment
  explicitly allows this as equivalent to an APK).
- No pagination, offline support, push notifications, test suite, or custom CI — out of scope for a
  4-hour prompting exercise; see `AGENTS.md` for the full list and rationale.

## If there were another hour

_TBD — first thing to improve, and why that one first._

## What this says about how software development is changing

_TBD._
