# 5-minute walkthrough

_Status: skeleton — filled in during Phase 6 once both apps are deployed._

A script for demoing both apps end to end, as if showing a real customer.

## 1. Dispatcher web app (~2 min)

1. Open the live dispatcher URL, sign in with Google.
2. Show the request list (empty state if nothing yet).
3. Create a new relocation request (origin, destination, date, notes) — point out validation.
4. Show it appear in the list with a `pending` status badge.
5. Edit the request (change a field, show it save).

## 2. Driver mobile app (~2 min)

1. Open the live driver web URL (or run the APK per README), sign in with Google.
2. Show "Available gigs" — the request just created should be listed.
3. Tap it, confirm the booking dialog, book it.
4. Show it disappear from "Available gigs" and appear in "My gigs".

## 3. Real-time sync tie-together (~1 min)

1. Switch back to the dispatcher app (already open, no refresh) and show the status has flipped
   to `booked` live.
2. Close with the one-line pitch: one shared source of truth, two purpose-built UIs, updating in
   near-real-time.

## Links

- Dispatcher web app: _TBD_
- Driver mobile app: _TBD_
- Repo: _TBD_
