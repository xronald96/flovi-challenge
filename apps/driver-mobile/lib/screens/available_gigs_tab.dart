import 'package:flutter/material.dart';
import '../models/relocation_request.dart';
import '../services/supabase_service.dart';
import '../widgets/gig_card.dart';
import '../widgets/booking_sheet.dart';

class AvailableGigsTab extends StatelessWidget {
  const AvailableGigsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Filtered client-side rather than via a server-side .eq(): supabase_flutter's
    // stream() re-applies query filters to the initial fetch but not reliably to
    // rows updated by incoming realtime events, which left booked gigs stuck in
    // this list until the tab was rebuilt. Streaming the whole table and filtering
    // here keeps every emission correct.
    final stream = supabase
        .from('relocation_requests')
        .stream(primaryKey: ['id'])
        .order('scheduled_date');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load gigs. Pull to refresh.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!
            .map(RelocationRequest.fromJson)
            .where((r) => r.status == RelocationStatus.pending)
            .toList();

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No gigs available right now.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return GigCard(
              request: request,
              onTap: () => showBookingSheet(context, request),
            );
          },
        );
      },
    );
  }
}
