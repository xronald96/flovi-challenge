import 'package:flutter/material.dart';
import '../models/relocation_request.dart';
import 'status_badge.dart';

class GigCard extends StatelessWidget {
  final RelocationRequest request;
  final VoidCallback? onTap;

  const GigCard({super.key, required this.request, this.onTap});

  String _formatDate(String value) {
    final date = DateTime.parse(value);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request.origin} → ${request.destination}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(request.scheduledDate),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (request.notes != null && request.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  request.notes!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
