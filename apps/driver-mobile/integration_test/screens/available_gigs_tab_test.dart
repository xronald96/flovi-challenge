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

  testWidgets('shows the empty state with no gigs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AvailableGigsTab())));

    await pumpUntil(tester, () => find.text('No gigs available right now.').evaluate().isNotEmpty);
  });

  testWidgets('shows a seeded pending gig', (tester) async {
    await seedRelocationRequest(origin: 'Chicago, IL', destination: 'Austin, TX', scheduledDate: '2099-01-01');

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AvailableGigsTab())));

    await pumpUntil(tester, () => find.text('Chicago, IL → Austin, TX').evaluate().isNotEmpty);
  });
}
