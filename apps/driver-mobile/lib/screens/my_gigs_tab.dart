import 'package:flutter/material.dart';
import '../models/relocation_request.dart';
import '../services/supabase_service.dart';
import '../widgets/gig_card.dart';

class MyGigsTab extends StatelessWidget {
  const MyGigsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    final stream = supabase
        .from('relocation_requests')
        .stream(primaryKey: ['id'])
        .eq('booked_by', userId)
        .order('scheduled_date');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load your gigs. Pull to refresh.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.map(RelocationRequest.fromJson).toList();

        if (requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checklist_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "You haven't booked any gigs yet.",
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
          itemBuilder: (context, index) => GigCard(request: requests[index]),
        );
      },
    );
  }
}
