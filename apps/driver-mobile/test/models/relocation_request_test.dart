import 'package:flutter_test/flutter_test.dart';
import 'package:driver_mobile/models/relocation_request.dart';

void main() {
  group('statusFromString', () {
    test('parses every known status', () {
      expect(statusFromString('pending'), RelocationStatus.pending);
      expect(statusFromString('booked'), RelocationStatus.booked);
      expect(statusFromString('completed'), RelocationStatus.completed);
      expect(statusFromString('cancelled'), RelocationStatus.cancelled);
    });

    test('falls back to pending for an unknown value', () {
      expect(statusFromString('some-future-status'), RelocationStatus.pending);
    });
  });

  group('RelocationRequest.fromJson', () {
    test('parses a full row', () {
      final request = RelocationRequest.fromJson({
        'id': 'req-1',
        'origin': 'Chicago, IL',
        'destination': 'Austin, TX',
        'scheduled_date': '2099-01-01',
        'notes': 'Fragile',
        'status': 'booked',
        'created_by': 'user-1',
        'booked_by': 'user-2',
      });

      expect(request.id, 'req-1');
      expect(request.origin, 'Chicago, IL');
      expect(request.destination, 'Austin, TX');
      expect(request.scheduledDate, '2099-01-01');
      expect(request.notes, 'Fragile');
      expect(request.status, RelocationStatus.booked);
      expect(request.createdBy, 'user-1');
      expect(request.bookedBy, 'user-2');
    });

    test('handles null notes and booked_by', () {
      final request = RelocationRequest.fromJson({
        'id': 'req-2',
        'origin': 'Denver, CO',
        'destination': 'Phoenix, AZ',
        'scheduled_date': '2099-01-01',
        'notes': null,
        'status': 'pending',
        'created_by': 'user-1',
        'booked_by': null,
      });

      expect(request.notes, isNull);
      expect(request.bookedBy, isNull);
    });
  });
}
