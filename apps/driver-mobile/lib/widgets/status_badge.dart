import 'package:flutter/material.dart';
import '../models/relocation_request.dart';

class StatusBadge extends StatelessWidget {
  final RelocationStatus status;

  const StatusBadge({super.key, required this.status});

  static const _colors = {
    RelocationStatus.pending: (Color(0xFFFEF3C7), Color(0xFF92400E)),
    RelocationStatus.booked: (Color(0xFFDBEAFE), Color(0xFF1E40AF)),
    RelocationStatus.completed: (Color(0xFFD1FAE5), Color(0xFF065F46)),
    RelocationStatus.cancelled: (Color(0xFFF3F4F6), Color(0xFF4B5563)),
  };

  static const _labels = {
    RelocationStatus.pending: 'Pending',
    RelocationStatus.booked: 'Booked',
    RelocationStatus.completed: 'Completed',
    RelocationStatus.cancelled: 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        _labels[status]!,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
