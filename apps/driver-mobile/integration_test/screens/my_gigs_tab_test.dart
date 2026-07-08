import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_mobile/screens/my_gigs_tab.dart';

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

  testWidgets('shows the empty state with no booked gigs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MyGigsTab())));

    await pumpUntil(tester, () => find.text("You haven't booked any gigs yet.").evaluate().isNotEmpty);
  });

  testWidgets('shows a gig booked by the current user', (tester) async {
    final id = await seedRelocationRequest(
      origin: 'Seattle, WA',
      destination: 'Portland, OR',
      scheduledDate: '2099-01-01',
    );
    await forceUpdateStatus(id, status: 'booked', bookedBy: testUserId);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MyGigsTab())));

    await pumpUntil(tester, () => find.text('Seattle, WA → Portland, OR').evaluate().isNotEmpty);
  });
}
