enum SessionStatus { pending, inProgress, completed, cancelled, unknown }

class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.startAt,
    required this.durationMinutes,
    required this.subject,
    required this.tutorName,
    required this.childName,
    required this.status,
  });

  final String id;
  final DateTime startAt;
  final int durationMinutes;
  final String subject;
  final String tutorName;
  final String childName;
  final SessionStatus status;
}
