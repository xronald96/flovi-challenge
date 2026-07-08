import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_mobile/models/relocation_request.dart';
import 'package:driver_mobile/widgets/status_badge.dart';

void main() {
  testWidgets('renders the correct label for every status', (tester) async {
    for (final entry in {
      RelocationStatus.pending: 'Pending',
      RelocationStatus.booked: 'Booked',
      RelocationStatus.completed: 'Completed',
      RelocationStatus.cancelled: 'Cancelled',
    }.entries) {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBadge(status: entry.key))),
      );

      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
