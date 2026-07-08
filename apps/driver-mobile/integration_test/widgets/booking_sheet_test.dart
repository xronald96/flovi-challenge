import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_mobile/screens/available_gigs_tab.dart';

import '../test_helper.dart';

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

  testWidgets('shows a friendly message when the gig was booked by someone else first', (tester) async {
    // Regression test for the exact race condition fixed in the initial build: the
    // booking mutation used to only filter on status='pending', and Supabase doesn't
    // error on a zero-row update, so a losing bid would have silently shown success.
    final id = await seedRelocationRequest(
      origin: 'Miami, FL',
      destination: 'Orlando, FL',
      scheduledDate: '2099-01-01',
    );

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AvailableGigsTab())));
    await pumpUntil(tester, () => find.text('Miami, FL → Orlando, FL').evaluate().isNotEmpty);

    await tester.tap(find.text('Miami, FL → Orlando, FL'));
    await pumpUntil(tester, () => find.text('Confirm booking').evaluate().isNotEmpty);

    // Simulate another driver winning the race between opening the sheet and
    // confirming. booked_by has a foreign-key constraint against auth.users, so this
    // reuses the only real user id available rather than a made-up one — what matters
    // for this test is that status is no longer 'pending' when the confirm lands.
    await forceUpdateStatus(id, status: 'booked', bookedBy: testUserId);

    await tester.tap(find.text('Confirm booking'));

    await pumpUntil(
      tester,
      () => find.text('This gig was just booked by someone else.').evaluate().isNotEmpty,
    );
  });
}
