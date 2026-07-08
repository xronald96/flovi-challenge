import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_mobile/screens/available_gigs_tab.dart';

import '../test_helper.dart';

// Kept in its own file/process rather than alongside available_gigs_tab_test.dart's
// other tests: reacting to a *live* realtime update (as opposed to an initial fetch)
// turned out to be sensitive to realtime channel subscribe/unsubscribe churn from
// earlier widget mounts in the same process — reliable when it's the first subscription
// ever made in the process, flaky/slow after a couple of prior mount+dispose cycles.
// Isolating it avoids that churn entirely rather than papering over it with a longer
// timeout (which didn't fix it — see PROMPT_LOG.md).
void main() {
  setUpAll(() async {
    await initTestSupabase();
  });

  setUp(() async {
    await wipeRelocationRequests();
  });

  tearDownAll(() async {
    await wipeRelocationRequests();
  });

  testWidgets('booking a gig removes it from Available live, no rebuild needed', (tester) async {
    // Regression test for the Phase 4 bug: supabase_flutter's stream().eq() didn't
    // reliably re-apply its filter to rows changed by incoming realtime events, so a
    // just-booked gig stayed listed here until the tab was rebuilt.
    await seedRelocationRequest(origin: 'Denver, CO', destination: 'Phoenix, AZ', scheduledDate: '2099-01-01');

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AvailableGigsTab())));
    await pumpUntil(tester, () => find.text('Denver, CO → Phoenix, AZ').evaluate().isNotEmpty);

    await tester.tap(find.text('Denver, CO → Phoenix, AZ'));
    await pumpUntil(tester, () => find.text('Confirm booking').evaluate().isNotEmpty);

    await tester.tap(find.text('Confirm booking'));

    await pumpUntil(tester, () => find.text('Denver, CO → Phoenix, AZ').evaluate().isEmpty);
  });
}
