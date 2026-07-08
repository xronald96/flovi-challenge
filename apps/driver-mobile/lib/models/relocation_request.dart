// Mirrors packages/shared/model.md — keep in sync with supabase/schema.sql.

enum RelocationStatus { pending, booked, completed, cancelled }

RelocationStatus statusFromString(String value) {
  return RelocationStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => RelocationStatus.pending,
  );
}

class RelocationRequest {
  final String id;
  final String origin;
  final String destination;
  final String scheduledDate;
  final String? notes;
  final RelocationStatus status;
  final String createdBy;
  final String? bookedBy;

  RelocationRequest({
    required this.id,
    required this.origin,
    required this.destination,
    required this.scheduledDate,
    required this.notes,
    required this.status,
    required this.createdBy,
    required this.bookedBy,
  });

  factory RelocationRequest.fromJson(Map<String, dynamic> json) {
    return RelocationRequest(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      scheduledDate: json['scheduled_date'] as String,
      notes: json['notes'] as String?,
      status: statusFromString(json['status'] as String),
      createdBy: json['created_by'] as String,
      bookedBy: json['booked_by'] as String?,
    );
  }
}
