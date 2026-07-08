import 'package:flutter/material.dart';
import '../models/relocation_request.dart';
import '../services/supabase_service.dart';

Future<void> showBookingSheet(BuildContext context, RelocationRequest request) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _BookingSheetContent(request: request),
  );
}

class _BookingSheetContent extends StatefulWidget {
  final RelocationRequest request;

  const _BookingSheetContent({required this.request});

  @override
  State<_BookingSheetContent> createState() => _BookingSheetContentState();
}

class _BookingSheetContentState extends State<_BookingSheetContent> {
  bool _submitting = false;
  String? _error;

  Future<void> _confirmBooking() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _error = 'You must be signed in to book a gig.';
        _submitting = false;
      });
      return;
    }
    try {
      final updated = await supabase
          .from('relocation_requests')
          .update({'status': 'booked', 'booked_by': userId})
          .eq('id', widget.request.id)
          .eq('status', 'pending')
          .select();

      if (updated.isEmpty) {
        setState(() {
          _error = 'This gig was just booked by someone else.';
          _submitting = false;
        });
        return;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig booked!')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${request.origin} → ${request.destination}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(request.scheduledDate, style: TextStyle(color: Colors.grey.shade600)),
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(request.notes!),
          ],
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _confirmBooking,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(_submitting ? 'Booking…' : 'Confirm booking'),
            ),
          ),
        ],
      ),
    );
  }
}
